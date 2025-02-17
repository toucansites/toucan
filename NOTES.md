# Notes

Developer notes and other useful things

## Naming conventions

- location is always URL
- path is always String


rendering sitemap / rss:

sitemap.xml/index.yml

```yaml
#slug: sitemap.xml
type: sitemap 
# template: sitemap
#output: 
#  path: 
#  file: sitemap
#  ext: xml
```

renderer:
    lastUpdateTypes: ["post"]
    
    cumulativeLastUpdateTypes: ["post", "podcast"]
    vs 
    aggregatedLastUpdateTypes: [...]

{{site.lastUpdate.full}}

publication date for RSS? (most recent item lmoddate globally?)

redirect renderer

```yaml
redirects/
  noindex.yml
    old-url/index.yml
      type:
        redirect
      code: 301
```
 
custom rss properties via template params... 💡
contenttype: sitemap -> query necessary things
iterate through the query results in the mustache template

contents
    index.yml
        baseUrl
        locale
        timeZone
        name
        +userDefined
    
themes
    default
    overrides

pipelines
    html.yaml   
        themes url
       
    json.yaml

config.yml

    pipelines
        path
    
    contents
        path:
        assets
            path
        
    dateFormats
        input: ""
        output:
            full: ""
