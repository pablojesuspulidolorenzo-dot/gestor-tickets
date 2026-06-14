import bleach
import markdown


def render_markdown_safe(markdown_text: str) -> str:
    """
    Convierte Markdown a HTML seguro para resúmenes IA.
    No permite scripts ni HTML activo.
    """
    if not markdown_text:
        return ""

    html = markdown.markdown(markdown_text)

    allowed_tags = [
        "p",
        "br",
        "strong",
        "em",
        "ul",
        "ol",
        "li",
        "blockquote",
        "code",
        "pre",
        "h3",
        "h4",
        "span",
        "a",
    ]
    allowed_attrs = {
        "a": ["href", "title", "target", "rel"],
        "*": ["class"],
    }
    allowed_protocols = ["http", "https", "mailto"]

    return bleach.clean(
        html,
        tags=allowed_tags,
        attributes=allowed_attrs,
        protocols=allowed_protocols,
        strip=True,
    )
