#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>


// Global variables for the output buffer.
static int bufsize;
static unsigned char buffer[128];
static unsigned char *bufptr;
static int byteswritten;

// Bit sizes.
#define BACK_LEN_BITS 3
#define BACK_OFF_BITS 12
#define RLE_BITS 6
#define LIT_BITS 6

// Global arrays for the compression statistics.
static unsigned long stat_literal[128];
static unsigned long stat_backref[(1 << BACK_OFF_BITS) * (1 << BACK_LEN_BITS)];

// Commandline options.
static signed int opt_skip = 0;
static signed int opt_verbosity = 1;


#define min(A, B) ((A) < (B) ? (A) : (B))


// Write a byte to the output stream.
void writebyte(FILE *outfh, unsigned char byte) {
    if (fputc(byte, outfh) == EOF) {
        perror("write error");
        exit(3);
    }
    ++byteswritten;
}


// Initialize the output buffer.
void initbuffer(void) {
    bufptr = buffer;
    bufsize = 0;
}


// Put a byte in the output buffer.
void bufferbyte(unsigned char byte) {
    *bufptr++ = byte;
    ++bufsize;
}


// Flush the output buffer.
void flushbuffer(FILE *outfh) {
    if (bufsize) {
        stat_literal[bufsize - 1]++;
        //printf("Writing %d bytes\n", bufsize);
        writebyte(outfh, bufsize);
        bufptr = buffer;
        while (bufsize) {
            writebyte(outfh, *bufptr++);
            --bufsize;
        }
    } else {
        //printf("Flushing empty buffer\n");
    }
    bufptr = buffer;
}

// Find the longest matching back reference.
int findlongestmatch(unsigned char *in, unsigned char *buf, int maxlen, int bufsize, int *retoffset) {
    int matchlen = 0;
    int matchoffset = 0;
    int len;
    int offset = bufsize;
    
    // printf("searching %d byte buffer at %08x data at %08x\n", bufsize, buf, in);
    while (bufsize) {
        if (*buf == *in) {
            len = 1;
            // while (len < maxlen && len < bufsize && buf[len] == in[len]) { // crazy _d!
            while (len < maxlen && buf[len] == in[len]) {
                ++len;
            }
            if (len > matchlen) {
                matchlen = len;
                matchoffset = offset;
            }
        }
        ++buf;
        --offset;
        --bufsize;
    }
    
    *retoffset = matchoffset & ((1 << BACK_OFF_BITS) - 1);
    return(matchlen);
}

// Count the number of repeating bytes.
int countrle(unsigned char *in, unsigned char lastbyte, int maxlen) {
    int len = 0;

    while (len < maxlen && *in == lastbyte) {
        ++len;
        ++in;
    }
    return len;
}

// Pack the data in memory.
int backpack(unsigned char *data, int filesize, FILE *outfh) {
    unsigned char *inptr, *backptr;
    unsigned char b;
    int bytesleft, bytesdone;
    int maxlen, backbufsize;
    int matchlen, matchoffset;
    int rlelen;
    
    inptr = data;
    bytesleft = filesize;
    bytesdone = 0;
    initbuffer();
    byteswritten = 0;
    
    // While there are still bytes left to compress...
    while (bytesleft) {
        
        // ...find a match if there are written bytes, and some more input data.
        if (bytesdone && bytesleft) {
            maxlen = min(bytesleft, (1 << BACK_LEN_BITS) + 2);
            backbufsize = min(bytesdone, (1 << BACK_OFF_BITS));
            backptr = inptr - backbufsize;
            matchlen = findlongestmatch(inptr, backptr, maxlen, backbufsize, &matchoffset);
            rlelen = countrle(inptr, inptr[-1], min(bytesleft, (1 << RLE_BITS) + 1));
        } else {
            matchlen = 0;
            rlelen = 0;
        }
        if (rlelen >= matchlen) {
            matchlen = 0;
        } else {
            rlelen = 0;
        }
        
        // If the match is at least 3 bytes, write a back reference.
        if (matchlen >= 3) {
            flushbuffer(outfh);
            stat_backref[matchoffset * (1 << BACK_LEN_BITS) + (matchlen - 3)]++;
            writebyte(outfh, 0x80 | ((matchlen - 3) << (BACK_OFF_BITS - 8)) | ((((1 << BACK_OFF_BITS) - matchoffset) >> 8) & 0x0f));
            writebyte(outfh, ((1 << BACK_OFF_BITS) - matchoffset) & 0xff);
            bytesdone += matchlen;
            bytesleft -= matchlen;
            inptr += matchlen;
        // Emit repeat code if the RLE count is at least 2.
        } else if (rlelen >= 2) {
            flushbuffer(outfh);
            writebyte(outfh, rlelen - 2 + 0x40);
            bytesdone += rlelen;
            bytesleft -= rlelen;
            inptr += rlelen;
        } else {
            // Otherwise we write literal bytes.
            bufferbyte(*inptr);
            if (bufsize >= (1 << LIT_BITS) - 1) {
                flushbuffer(outfh);
            }
            ++bytesdone;
            --bytesleft;
            ++inptr;
        }
    }
    
    // Flush any leftover bytes.
    flushbuffer(outfh);
    
    // Write EOF marker.
    writebyte(outfh, 0);
    
    return(byteswritten);
}


void usage(void) {
    puts("Usage: backpack [-s skip_bytes] [-q] [-v] infile outfile\r\n");
}


int main(int argc, char **argv) {
    char *inname, *outname;
    int insize, outsize;
    int bytesread = 0;
    FILE *infile, *outfile;
    unsigned char *rambuf;
    int l;
    int opt;
    int skipped = 0;
    unsigned char skipbuf[256];
    
    // Reset the statistics.
    memset(stat_literal, 0, sizeof(stat_literal));
    memset(stat_backref, 0, sizeof(stat_backref));
    
    // Parse args.
    while ((opt = getopt(argc, argv, "s:qvh")) != -1) {
        switch (opt) {
            case 's':
                opt_skip = strtol(optarg, (char **)NULL, 10);
                if (opt_skip < 1) {
                    usage();
                    return(1);
                }
                break;
            case 'q':
                opt_verbosity = 0;
                break;
            case 'v':
                opt_verbosity = 2;
                break;
            case 'h':
                usage();
                return(0);
                break;
            default:
                usage();
                return(1);
        }
    }
    argc -= optind;
    argv += optind;
    
    if (argc < 2) {
        usage();
        return(1);
    }
    
    inname = argv[0];
    outname = argv[1];
    
    // Open input and output files.
    if ((infile = fopen(inname, "rb")) == NULL) {
        fprintf(stderr, "%s: ", inname);
        perror("couldn't open for reading");
        return(1);
    }
    
    if ((outfile = fopen(outname, "wb")) == NULL) {
        fclose(infile);
        fprintf(stderr, "%s: ", inname);
        perror("couldn't open for writing");
        return(1);
    }
    
    // Determine input file length.
    if (fseek(infile, 0, SEEK_END) != 0) {
        perror("Couldn't determine file size");
        goto error;
    }
    insize = ftell(infile);
    if (fseek(infile, 0, SEEK_SET) != 0) {
        perror("Seek failed");
        goto error;
    }
    
    // Skip bytes.
    if (opt_skip) {
        while (skipped < opt_skip) {
            if ((l = fread(skipbuf, 1, min(sizeof(skipbuf), opt_skip - skipped), infile)) == 0) {
                perror("Couldn't read data");
                goto error;
            }
            if (fwrite(skipbuf, 1, min(sizeof(skipbuf), opt_skip - skipped), outfile) != l) {
                perror("Couldn't write data");
                goto error;
            }
            skipped += l;
        }
        insize -= skipped;
    }
    
    // Read input file into ram.
    if ((rambuf = malloc(insize)) == NULL) {
        fprintf(stderr, "Out of memory (need %d bytes)\n", insize);
        goto error;
    }
    while (bytesread < insize) {
        if ((l = fread(rambuf + bytesread, 1, min(4096, insize - bytesread), infile)) == 0) {
            perror("Couldn't read data");
            free(rambuf);
            goto error;
        }
        bytesread += l;
    }
    
    // Pack.
    outsize = backpack(rambuf, insize, outfile);
    
    // We're done with the input file.
    free(rambuf);
    
    // Print html header.
    if (opt_verbosity >= 2) {
        puts("<html>");
        puts("<header>");
        puts("<title>Backpack Output Statistics</title>");
        puts("<style type=\"text/css\">");
        puts("td {");
        puts("  min-width: 2em;");
        puts("  text-align: center;");
        puts("}");
        puts("th.offset {");
        puts("  min-width: 2em;");
        puts("}");
        puts("</style>");
        puts("</header>");
        puts("<body>");
        printf("<h1>%s</h1>", inname);
    }
    
    // Print terse stats.
    if (opt_verbosity >= 1) {
        printf("Input %d bytes, output %d bytes, ratio %.1f%%\r\n", insize, outsize, (double) ((100.0 * (double) outsize) / (double) insize));
    }
    
    // Print verbose stats.
    if (opt_verbosity >= 2) {
        int x, y;
        
        puts("<h2>Literal runs</h2>");
        puts("<table border=\"1\" cellspacing=\"0\" cellpadding=\"1\">");
        puts("<tr><th>Length</th><th>Count</th></tr>");
        for (l = 0; l < 128; ++l) {
            if (stat_literal[l]) {
                printf("<tr><td>%d</td><td>%ld</td></tr>\n", l + 1, stat_literal[l]);
            } else {
                printf("<tr><td>%d</td><td></td></tr>\n", l + 1);
            }
        }
        puts("</table>");
        
        puts("<h2>Back references</h2>");
        puts("<table border=\"1\" cellspacing=\"0\" cellpadding=\"1\">");
        printf("<tr><th class=\"offset\"></th>");
        for (x = 0; x < 127; ++x) {
            printf("<th>%d</th>", x + 3);
        }
        puts("</tr>");
        for (y = (1 << BACK_OFF_BITS) - 1; y >= 0; --y) {
            printf("<tr><th>%d</th>", y - (1 << BACK_OFF_BITS));
            for (x = 0; x < (1 << BACK_LEN_BITS); ++x) {
                if (stat_backref[y * (1 << BACK_LEN_BITS) + x]) {
                    printf("<td>%ld</td>", stat_backref[y * (1 << BACK_LEN_BITS) + x]);
                } else {
                    printf("<td></td>");
                }
            }
            puts("</tr>");
        }
        puts("</table>");
    }
    
    // Print html footer.
    if (opt_verbosity >= 2) {
        puts("</body>");
        puts("</html>");
    }
    
    // Close and exit.
    fclose(infile);
    fclose(outfile);
    return(0);
    
error:
    fclose(infile);
    fclose(outfile);
    return(2);
}
