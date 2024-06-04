//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 21/05/2024.
//

struct HTMLPageState<T> {
    
    struct CurrentPageState<C> {
        let slug: String
        let metadata: MetadataState
        let context: C
        let content: String
    }

    let site: SiteState
    let page: CurrentPageState<T>
    let userDefined: [String: Any]
    let year: Int
    let template: String
}


typealias AuthorListHTMLPageState = HTMLPageState<AuthorListState>
typealias AuthorDetailHTMLPageState = HTMLPageState<AuthorDetailState>
typealias TagListHTMLPageState = HTMLPageState<TagListState>
typealias TagDetailHTMLPageState = HTMLPageState<TagDetailState>
typealias PostListHTMLPageState = HTMLPageState<PostListState>
typealias PostDetailHTMLPageState = HTMLPageState<PostDetailState>
typealias PageDetailHTMLPageState = HTMLPageState<PageState>
typealias HomeHTMLPageState = HTMLPageState<HomeState>
typealias NotFoundHTMLPageState = HTMLPageState<NotFoundState>
typealias BlogHTMLPageState = HTMLPageState<BlogState>
