# Toucan

Toucan is a static site generator written in Swift.


## Directory structure

```
src
    contents
        posts
            post1
                post1.md
                post1-cover.jpg
        pages
            page1
                contents.md

        404.md
        index.md
        home.md

    templates
        index.html
        home.html
        home-posts.html
        404.html
        page.html
        post.html

    public
        * (everyting copied as it is)
```

## Metadata keys

Required:
- slug
- title
- description
- date

Optional:
- template


## Configuration

site.config.md

- site.baseUrl: 
- site.language:
- site.name: 
- site.description: 
- site.imageUrl: 

- posts.slug = posts
- posts.limit = 10

## Pagination & tags

/posts.html 
/posts/page/1.html -> canonical blog.html
/posts/page/2.html
/posts/page/3.html


/tags               => list of all tags
/tags/foo.html
/tags/bar.html


/authors
/authors/tibor-bodecs




## Template render pipeline


index->home->post
index->404
index->page
index->post


site->index->post

site.html
@@@
site.title
site.slug
site.description

index.html
@@@
site.index.title
site.index.description

global variables
{site.index}

local variables:
{$.title}
{$.description}
{$.tags|<a href="asdf">$</a>}


search:
    index.json
        [
            {
                "keywords": [
                    "foo", 
                    "bar", 
                    "baz"
                ]
                "item": {
                    "title": "",
                    "description": "",
                    "permalink": ""
                    "coverImage": ""
                }
            }
        ]

    javascript api call
