class ColorLibrary:
    color_map = {
        "red": "#ff0000",
        "blue": "#0000ff",
        "green": "#00ff00",
        "yellow": "#ffff00",
        "purple": "#800080",
        "orange": "#ffa500",
        "pink": "#ffc0cb",
        "cyan": "#00ffff",
        "magenta": "#ff00ff",
        "lime": "#00ff00",
        "teal": "#008080",
        "brown": "#a52a2a",
        "white": "#ffffff",
        "black": "#000000",
        "gray": "#808080",
        "maroon": "#800000",
        "navy": "#000080",
        "olive": "#808000",
        "silver": "#c0c0c0",
        "gold": "#ffd700",
        "beige": "#f5f5dc",
        "ivory": "#fffff0",
        "coral": "#ff7f50",
        "turquoise": "#40e0d0",
        "indigo": "#4b0082",
        "violet": "#ee82ee",
        "chartreuse": "#7fff00",
        "aquamarine": "#7fffd4",
        "orchid": "#da70d6",
        "plum": "#dda0dd",
        "salmon": "#fa8072"
    }

    @classmethod
    def get_hex(cls, color_name):
        return cls.color_map.get(color_name.lower(), None)
