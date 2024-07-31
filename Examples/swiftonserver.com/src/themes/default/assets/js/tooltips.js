// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. https://github.com/tayloraswift/swift-unidoc?tab=MPL-2.0-1-ov-file

const tooltips = document.getElementById('ss:tooltips');

if (tooltips !== null) {
    tooltips.remove();
    //  The tooltips `<div>` contains `<a>` elements only.
    let cards = {};
    let frame = document.createElement('div');

    for (const anchor of tooltips.children) {
        if (!(anchor instanceof HTMLAnchorElement)) {
            continue;
        }

        //  Cannot use `anchor.href`, we want the exact value of the `href` attribute.
        const id = anchor.getAttribute("href")

        if (id === null) {
            continue;
        }

        //  Change the tooltip into a `<div>` with `class="tooltip"`.
        const tooltip = document.createElement('div');
        tooltip.innerHTML = anchor.innerHTML;

        cards[id] = tooltip;
        frame.appendChild(tooltip);
    }

    //  Inject the tooltips into every `<a>` element with the same `href` attribute.
    //  This should only be done within the `<main>` element.
    const main = document.querySelector('main');
    if (main !== null) {
        main.querySelectorAll('a').forEach((
            anchor,
            key,
            all
        ) => {

            //  If the anchor is inside a card preview, the tooltip would be redundant.
            if (anchor.parentElement?.tagName === 'CODE' &&
                anchor.parentElement.classList.contains('decl')) {
                return;
            }
            if (anchor.parentElement?.tagName === 'H3' &&
                anchor.parentElement.classList.contains('module')) {
                return;
            }

            let id = anchor.getAttribute("href");

            if (id === null) {
                return;
            }

            const hostname = "https://swiftinit.org"
            if (id.startsWith(hostname)) {
                id = id.substring(hostname.length);
            }

            const tooltip = cards[id];

            if (tooltip === undefined) {
                return;
            }

            //  When you hover over the anchor, show the tooltip by loading the (x, y) position
            //  of the anchor on the screen, and then adding the tooltip to the document as
            //  a fixed-position element.
            anchor.addEventListener('mouseenter', (event) => {
                const r = anchor.getBoundingClientRect();

                tooltip.style.left = r.x.toString() + 'px';
                tooltip.style.top = r.bottom.toString() + 'px';

                tooltip.classList.add('visible');
            });
            anchor.addEventListener('mouseleave', (event) => {
                tooltip.classList.remove('visible');
            });
        });

        //  Make the tooltips list visible; it was originally hidden to prevent FOUC.
        frame.className = 'tooltips';
        document.body.appendChild(frame);
    }
}
