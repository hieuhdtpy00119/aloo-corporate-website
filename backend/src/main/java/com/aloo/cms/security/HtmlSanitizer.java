package com.aloo.cms.security;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.safety.Safelist;

public final class HtmlSanitizer {

    private static final Safelist SAFELIST = Safelist.relaxed()
            .addTags("h1", "h2", "h3", "h4", "h5", "h6", "figure", "figcaption", "picture", "source")
            .addAttributes(":all", "class", "id")
            .addAttributes("a", "target", "rel")
            .addAttributes("img", "loading", "decoding")
            .addAttributes("source", "srcset", "type", "media")
            .addProtocols("a", "href", "http", "https", "mailto")
            .addProtocols("img", "src", "http", "https")
            .addProtocols("source", "srcset", "http", "https");

    private HtmlSanitizer() {
    }

    public static String sanitize(String html) {
        if (html == null || html.isBlank()) {
            return html;
        }

        Document.OutputSettings settings = new Document.OutputSettings().prettyPrint(false);
        return Jsoup.clean(html, "", SAFELIST, settings);
    }
}
