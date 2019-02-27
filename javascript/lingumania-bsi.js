/*
LICENSE AND TERMS OF USE

Lingumania.js is licensed under the terms of https://creativecommons.org/licenses/by-nd/3.0/ license, 
which means it can be used freely on commercial or non commercial websites as long as the language switcher links back to www.lingumania.com. 
You may modify the code only if you use it to translate your own website. In all other cases, modifications or redistribution, 
whether standalone or as part of another javascript, are not permitted without prior consent of the copyright owners.
*/

(function (w, d, u) {

    var NodeFilter = {
        FILTER_ACCEPT: 1,
        FILTER_REJECT: 2,
        FILTER_SKIP: 3,
        SHOW_ALL: -1,
        SHOW_ELEMENT: 1,
        SHOW_ATTRIBUTE: 2,
        SHOW_TEXT: 4,
        SHOW_CDATA_SECTION: 8,
        SHOW_ENTITY_REFERENCE: 16,
        SHOW_ENTITY: 32,
        SHOW_PROCESSING_INSTRUCTIONS: 64,
        SHOW_COMMENT: 128,
        SHOW_DOCUMENT: 256,
        SHOW_DOCUMENT_TYPE: 512,
        SHOW_DOCUMENT_FRAGMENT: 1024,
        SHOW_NOTATION: 2048
    };

    var TreeWalker = function (root, whatToShow, filter, expandEntityReferences) {
        this.root = root;
        this.whatToShow = whatToShow;
        this.filter = filter;
        this.expandEntityReferences = expandEntityReferences;
        this.currentNode = root;
        this.NodeFilter = NodeFilter;
    };

    TreeWalker.prototype.parentNode = function () {
        var testNode = this.currentNode;

        do {
            if (
                testNode !== this.root &&
                testNode.parentNode &&
                testNode.parentNode !== this.root
            ) {
                testNode = testNode.parentNode;
            } else {
                return null;
            }
        } while (this._getFilteredStatus(testNode) !== this.NodeFilter.FILTER_ACCEPT);
        (testNode) && (this.currentNode = testNode);

        return testNode;
    };

    TreeWalker.prototype.firstChild = function () {
        var testNode = this.currentNode.firstChild;

        while (testNode) {
            if (this._getFilteredStatus(testNode) === this.NodeFilter.FILTER_ACCEPT) {
                break;
            }
            testNode = testNode.nextSibling;
        }
        (testNode) && (this.currentNode = testNode);

        return testNode;
    };

    TreeWalker.prototype.lastChild = function () {
        var testNode = this.currentNode.lastChild;

        while (testNode) {
            if (this._getFilteredStatus(testNode) === this.NodeFilter.FILTER_ACCEPT) {
                break;
            }
            testNode = testNode.previousSibling;
        }
        (testNode) && (this.currentNode = testNode);

        return testNode;
    };

    TreeWalker.prototype.nextNode = function () {
        var testNode = this.currentNode;

        while (testNode) {
            if (testNode.childNodes.length !== 0) {
                testNode = testNode.firstChild;
            } else if (testNode.nextSibling) {
                testNode = testNode.nextSibling;
            } else {
                while (testNode) {
                    if (testNode.parentNode && testNode.parentNode !== this.root) {
                        if (testNode.parentNode.nextSibling) {
                            testNode = testNode.parentNode.nextSibling;
                            break;
                        } else {
                            testNode = testNode.parentNode;
                        }
                    }
                    else return null;
                }
            }
            if (testNode && this._getFilteredStatus(testNode) === this.NodeFilter.FILTER_ACCEPT) {
                break;
            }
        }
        (testNode) && (this.currentNode = testNode);

        return testNode;
    };

    TreeWalker.prototype.previousNode = function () {
        var testNode = this.currentNode;

        while (testNode) {
            if (testNode.previousSibling) {
                testNode = testNode.previousSibling;
                while (testNode.lastChild) {
                    testNode = testNode.lastChild;
                }
            }
            else {
                if (testNode.parentNode && testNode.parentNode !== this.root) {
                    testNode = testNode.parentNode;
                }
                else testNode = null;
            }
            if (testNode && this._getFilteredStatus(testNode) === this.NodeFilter.FILTER_ACCEPT) {
                break;
            }
        }
        (testNode) && (this.currentNode = testNode);

        return testNode;
    };

    TreeWalker.prototype.nextSibling = function () {
        var testNode = this.currentNode;

        while (testNode) {
            (testNode.nextSibling) && (testNode = testNode.nextSibling);
            if (this._getFilteredStatus(testNode) === this.NodeFilter.FILTER_ACCEPT) {
                break;
            }
        }
        (testNode) && (this.currentNode = testNode);

        return testNode;
    };

    TreeWalker.prototype.previousSibling = function () {
        var testNode = this.currentNode;

        while (testNode) {
            (testNode.previousSibling) && (testNode = testNode.previousSibling);
            if (this._getFilteredStatus(testNode) == this.NodeFilter.FILTER_ACCEPT) {
                break;
            }
        }
        (testNode) && (this.currentNode = testNode);

        return testNode;
    };

    TreeWalker.prototype._getFilteredStatus = function (node) {
        var mask = ({
            /* ELEMENT_NODE */ 1: this.NodeFilter.SHOW_ELEMENT,
            /* ATTRIBUTE_NODE */ 2: this.NodeFilter.SHOW_ATTRIBUTE,
            /* TEXT_NODE */ 3: this.NodeFilter.SHOW_TEXT,
            /* CDATA_SECTION_NODE */ 4: this.NodeFilter.SHOW_CDATA_SECTION,
            /* ENTITY_REFERENCE_NODE */ 5: this.NodeFilter.SHOW_ENTITY_REFERENCE,
            /* ENTITY_NODE */ 6: this.NodeFilter.SHOW_PROCESSING_INSTRUCTION,
            /* PROCESSING_INSTRUCTION_NODE */ 7: this.NodeFilter.SHOW_PROCESSING_INSTRUCTION,
            /* COMMENT_NODE */ 8: this.NodeFilter.SHOW_COMMENT,
            /* DOCUMENT_NODE */ 9: this.NodeFilter.SHOW_DOCUMENT,
            /* DOCUMENT_TYPE_NODE */ 10: this.NodeFilter.SHOW_DOCUMENT_TYPE,
            /* DOCUMENT_FRAGMENT_NODE */ 11: this.NodeFilter.SHOW_DOCUMENT_FRAGMENT,
            /* NOTATION_NODE */ 12: this.NodeFilter.SHOW_NOTATION
        })[node.nodeType];

        return (
            (mask && (this.whatToShow & mask) == 0) ?
                this.NodeFilter.FILTER_REJECT :
                (this.filter && this.filter.acceptNode) ?
                    this.filter.acceptNode(node) :
                    this.NodeFilter.FILTER_ACCEPT
        );
    };

    if (!d.createTreeWalker) {
        d.createTreeWalker = function (root, whatToShow, filter, expandEntityReferences) {
            return new TreeWalker(root, whatToShow, filter, expandEntityReferences);
        };
    }

    if (typeof String.prototype.trim !== 'function') {
        String.prototype.trim = function () {
            return this.replace(/^\s+|\s+$/g, '');
        }
    }

    String.prototype.startsWith = function (searchString) {
        return this.substr(0, searchString.length) === searchString;
    };

    String.prototype.endsWith = function (suffix) {

        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    };

    function getElementsByTagNames(tags) {
        var elements = [];

        for (var i = 0, n = tags.length; i < n; i++) {
            var divs = d.getElementsByTagName(tags[i]);
            for (var j = 0; j < divs.length; j++) {
                elements.push(divs[j]);
            }
        }

        return elements;
    };

    function isTranslatableSegment(html) {

        var foundPunctuation = html.match(/^(.|,|;|:|«|»|·|&|=|\/|\$|€|£|\(|\)|\*|\-|\+|\||\$-\/:-?{-~||\t|\r|\n|\d|\s)+$/gim);
        if (foundPunctuation) {
            var foundNonPunctuationChars = html.match(/[^.,;:€£«»·&=\/\$\(\)\*\-\+\|\t\r\n\d\s]/gim);
            if (!foundNonPunctuationChars)
                return false;
        }

        return true;
    }

    function encodeAllSpecialTags(html) {

        html = html.replace(/<b>/gim, "&lt;b&gt;").replace(/<\/b>/gim, "&lt;/b&gt;").replace(/<i>/gim, "&lt;i&gt;").replace(/<\/i>/gim, "&lt;/i&gt;").replace(/<u>/gim, "&lt;u&gt;").replace(/<\/u>/gim, "&lt;/u&gt;").replace(/<em>/gim, "&lt;em&gt;").replace(/<\/em>/gim, "&lt;/em&gt;").replace(/<\/strong>/gim, "&lt;/strong&gt;").replace(/<\/abbr>/gim, "&lt;/abbr&gt;").replace(/<\/sub>/gim, "&lt;/sub&gt;").replace(/<\/sup>/gim, "&lt;/sup&gt;").replace(/<\/big>/gim, "&lt;/big&gt;").replace(/<\/small>/gim, "&lt;/small&gt;");

        var searchText = /<b\s[^>]*>/gim;
        var matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<i\s[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<u\s[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<em\s[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<strong[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<abbr[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<sub[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<sup[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<big[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        searchText = /<small[^>]*>/gim;
        matches = searchText.exec(html);
        if (matches) {
            for (var i = 0; i < matches.length; i++) {
                html = html.replace(searchText, "&lt;" + matches[i].substring(1, matches[i].length - 1).toLowerCase() + "&gt;");
            }
        }

        return html;
    }

    function translateDOM() {
        if (linguJSON) {
			console.log("lingumania-bsi", "Found translation settings - processing.");
			
			if (!linguJSON.translated_segments)
				console.log("lingumania-bsi", "No translation segments found. Stopping.");
				
			if (!linguJSON.translation_enabled || linguJSON.translation_enabled !== true)
				console.log("lingumania-bsi", "Translation disabled. Stopping.");
				
            if (linguJSON.translated_segments && linguJSON.translation_enabled === true) {
				console.log("lingumania-bsi", "Translation enabled, and found translated segments. Proceeding with translation.");
				
                var translatedSegments = linguJSON.translated_segments;

                var specialTags = getElementsByTagNames(['b', 'u', 'i', 'strong', 'em', 'abbr', 'sub', 'sup', 'big', 'small']);
                for (var i = 0; i < specialTags.length; i++) {
                    if (specialTags[i].parentNode)
                        specialTags[i].parentNode.innerHTML = encodeAllSpecialTags(specialTags[i].parentNode.innerHTML);
                }

                var node, nodes = [], fragments = [], linkTranslations = [];
                var domWalker = d.createTreeWalker(d.getElementsByTagName('html')[0], NodeFilter.SHOW_ALL, null, false);

                while (node = domWalker.nextNode()) {
                    if (node.nodeValue != null) {
                        if (!isTranslatableSegment(node.nodeValue.trim()))
                            continue;

                        var canBeTranslated = true;
                        var current = node;
                        while (canBeTranslated && current.parentNode) {
                            current = current.parentNode;
                            if (current.nodeName == "STYLE") {
                                canBeTranslated = false;
                            } else if (current.attributes) {
                                for (var i = 0; i < current.attributes.length; i++) {
                                    if (current.attributes[i].value == "notranslate")
                                        canBeTranslated = false;
                                }
                            }
                        }

                        if (canBeTranslated) {
                            try {

                                var startingWhiteSpaceRegex = /^\s+/gim;
                                var startingWhiteSpaceMatches = startingWhiteSpaceRegex.exec(node.nodeValue);
                                var endingWhiteSpaceRegex = /\s+$/gim;
                                var endingWhiteSpaceMatches = endingWhiteSpaceRegex.exec(node.nodeValue);

                                for (var i = 0; i < translatedSegments.length; i++) {
                                    if (translatedSegments[i].target == undefined) {
                                        if (eval('translatedSegments[i].target_' + currlangcode))
                                            translatedSegments[i].target = eval('translatedSegments[i].target_' + currlangcode);
                                    }

                                    if (translatedSegments[i].source == node.nodeValue.trim() && translatedSegments[i].target) {

                                        var target = translatedSegments[i].target;

                                        if (startingWhiteSpaceMatches)
                                            target = startingWhiteSpaceMatches[0] + target;

                                        if (endingWhiteSpaceMatches)
                                            target += endingWhiteSpaceMatches[0];

                                        if (target.match(/<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[\^'">\s]+))?)+\s*|\s*)\/?>/gim)) {

                                            var wrap = d.createElement('span');
                                            var frag = d.createDocumentFragment();
                                            wrap.innerHTML = target.replace(/\\"/g, '"');

                                            while (wrap.firstChild) {
                                                frag.appendChild(wrap.firstChild);
                                            }
                                            nodes.push(node);
                                            fragments.push(frag);
                                        }
                                        else {
                                            node.nodeValue = target;
                                        }
                                        break;
                                    }
                                }

                            } catch (ex) {

                            }
                        }



                        if (node.nodeValue.match(/(<\/b|<b\s[^>]*>|<\/u>|<u\s[^>]*>|<\/i>|<i\s[^>]*>|<\/strong>|<strong[^>]*>|<\/em>|<em\s[^>]*>|<\/abbr>|<abbr[^>]*>|<\/sub>|<sub[^>]*>|<\/sup>|<sup[^>]*>|<\/big>|<big[^>]*>|<\/small>|<small[^>]*>)/gim)) {
                            var wrap = d.createElement('span');
                            var frag = d.createDocumentFragment();
                            wrap.innerHTML = node.nodeValue;

                            while (wrap.firstChild) {
                                frag.appendChild(wrap.firstChild);
                            }
                            nodes.push(node);
                            fragments.push(frag);
                        }

                    }
                }

                var inputs = d.getElementsByTagName('input');
                for (var i = 0; i < inputs.length; i++) {
                    var input = inputs[i];
                    if (isTranslatableSegment(input.value.trim())) {
                        for (var j = 0; j < translatedSegments.length; j++) {
                            if (translatedSegments[j].source == input.value.trim()) {
                                input.value = translatedSegments[j].target;
                                break;
                            }
                        }
                    }
                }

                var imgs = d.getElementsByTagName('img');
                for (var i = 0; i < imgs.length; i++) {
                    var img = imgs[i];
                    if (img.attributes["alt"] && isTranslatableSegment(img.attributes["alt"].value.trim())) {
                        for (var j = 0; j < translatedSegments.length; j++) {
                            if (translatedSegments[j].source == img.attributes["alt"].value.trim()) {
                                img.attributes["alt"].value = translatedSegments[j].target;
                                break;
                            }
                        }
                    }
                }

                var metas = d.getElementsByTagName('meta');
                for (var i = 0; i < metas.length; i++) {
                    var meta = metas[i];
                    if (meta.attributes["content"]) {
                        for (var j = 0; j < translatedSegments.length; j++) {
                            if (translatedSegments[j].source == meta.attributes["content"].value.trim()) {
                                meta.attributes["content"].value = translatedSegments[j].target;
                                break;
                            }
                        }
                    }
                }

                for (var i = 0; i < translatedSegments.length; i++) {
                    if (translatedSegments[i].target == undefined) {
                        if (eval('translatedSegments[i].target_' + currlangcode))
                            translatedSegments[i].target = eval('translatedSegments[i].target_' + currlangcode);
                    }
                    if (translatedSegments[i].target && translatedSegments[i].target.startsWith('http'))
                        linkTranslations.push(translatedSegments[i]);
                }

                for (var i = 0; i < nodes.length; i++) {
                    if (nodes[i].parentNode)
                        nodes[i].parentNode.replaceChild(fragments[i], nodes[i]);
                }

            }

            if (linguJSON.translated_image_segments && linguJSON.translated_image_segments.length > 0 && linguJSON.translation_enabled === true) {
                var translatedImageSegments = linguJSON.translated_image_segments;

                var imgs = d.getElementsByTagName('img');
                for (var i = 0; i < imgs.length; i++) {
                    var img = imgs[i];
                    if (img.attributes["src"]) {
                        for (var j = 0; j < translatedImageSegments.length; j++) {
                            if (translatedImageSegments[j].img_target == undefined) {
                                if (eval('translatedImageSegments[j].img_target_' + currlangcode))
                                    translatedImageSegments[j].img_target = eval('translatedImageSegments[j].img_target_' + currlangcode);
                            }
                            if (translatedImageSegments[j].img_source.replace('http://', '').replace('https://', '').endsWith(img.attributes["src"].value.trim().replace('http://', '').replace('https://', ''))) {
                                img.attributes["src"].value = translatedImageSegments[j].img_target;
                                break;
                            }
                        }
                    }
                }
            }
        }
		
		console.log("lingumania-bsi", "Translation complete, showing body content.");
        d.body.style.visibility = 'visible';
    }

    var linguLoader = function () {
		console.log("lingumania-bsi", "Hiding body content for translation.");
		d.body.style.visibility = "hidden";
		translateDOM();
    };

    w.addEventListener ? w.addEventListener("load", linguLoader, false) : w.attachEvent("onload", linguLoader);
}(window, document));
