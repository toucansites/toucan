//
//  sitebundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

struct SiteBundle {
    let contentBundles: [ContentBundle]
    let renderers: [Renderer]

    func render() {
        for renderer in renderers {
            renderer.render(contentBundles: contentBundles)
        }
    }
}
