import sys
import xml.etree.ElementTree as ET

path = sys.argv[1]
ET.register_namespace("", "http://www.w3.org/2000/svg")
ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")

tree = ET.parse(path)
root = tree.getroot()

bg = ET.Element(
    "{http://www.w3.org/2000/svg}rect",
    {
        "width": "100%",
        "height": "100%",
        "fill": "#f8f8f8",
    },
)
bg.tail = "\n  "
root.insert(0, bg)
tree.write(path, encoding="unicode", xml_declaration=True)
