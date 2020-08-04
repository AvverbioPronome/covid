---
---

# Something something

Something something something

## Indice

{% for page in site.pages %}
{% if {{ page.url | slice: -5 }} == ".html" %}
- [{{ page.title }}]({{ page.url }})
{% endif %}
{% endfor %}
