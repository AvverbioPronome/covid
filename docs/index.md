---
---

# Something something

Something something something

## Indice

{% for page in site.pages %}
{⅜ capture ext %}{{ page.url | slice: -5 }}{% endcapture %}
{% if ext == ".html" %}
- [{{ page.title }}]({{ page.url }})
{% endif %}
{% endfor %}
