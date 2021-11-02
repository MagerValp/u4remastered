import png


class ImageArray(object):
    """Arrays representing image data."""
    
    FORMAT_PNG=u"png"
    
    def __init__(self, width, height, mode=u"rgb", palette=None):
        super(ImageArray, self).__init__()
        self.width = width
        self.height = height
        self.mode = mode
        self.palette = palette
        if mode == u"rgb":
            self.bpp = 3
        elif mode == u"i":
            self.bpp = 1
            if self.palette is None:
                raise ValueError
        else:
            raise NotImplementedError
        self.rows = list(bytearray([0] * width * self.bpp) for x in range(self.height))
    
    @classmethod
    def load(cls, path):
        r = png.Reader(filename=path)
        width, height, pixels, metadata = r.read()
        if metadata[u"planes"] == 1:
            mode = u"i"
            palette = r.palette()
        elif metadata[u"planes"] == 3:
            mode = u"rgb"
            palette = None
        else:
            NotImplementedError
        image = ImageArray(width, height, mode, palette)
        image.rows = list(pixels)
        return image
    
    def save(self, path, format=None):
        if format is None:
            format = self.FORMAT_PNG
        
        if format == self.FORMAT_PNG:
            bitdepth = 8
            if self.mode == u"i":
                palette = self.palette
                if len(self.palette) <= 2:
                    bitdepth = 1
                if len(self.palette) <= 4:
                    bitdepth = 2
                if len(self.palette) <= 16:
                    bitdepth = 4
            else:
                palette = None
            w = png.Writer(self.width, self.height, bitdepth=bitdepth, palette=palette)
            with open(path, u"wb") as f:
                w.write(f, self.rows)
        else:
            raise NotImplementedError
    
    def set_pixel(self, x, y, value):
        if self.bpp == 1:
            self.rows[y][x] = value
        else:
            if len(value) != self.bpp:
                raise ValueError
            self.rows[y][x * self.bpp:(x + 1) * self.bpp] = bytearray(value)
    
    def get_pixel(self, x, y):
        if self.bpp == 1:
            return self.rows[y][x]
        else:
            return tuple(self.rows[y][x * self.bpp:(x + 1) * self.bpp])
    
    def blit(self, to_x, to_y, image, from_x=0, from_y=0, width=None, height=None):
        if image.mode != self.mode:
            raise NotImplementedError
        if width is None:
            width = image.width
        if height is None:
            height = image.height
        for dy in range(height):
            self.rows[to_y + dy][to_x:to_x + width] = image.rows[from_y + dy][from_x:from_x + width]
    
    def copy(self, x=0, y=0, width=None, height=None):
        if width is None:
            width = self.width
        if height is None:
            height = self.height
        sprite = ImageArray(width, height, mode=self.mode, palette=self.palette)
        sprite.blit(0, 0, self, x, y, width, height)
        return sprite
