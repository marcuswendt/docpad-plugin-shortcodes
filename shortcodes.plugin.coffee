
class Shortcode
    constructor: (@name, @replacer) ->


defaults = []
defaults.push new Shortcode 'vimeo', (attributes, content) ->
        attributes.id ?= '21657846'
        attributes.title ?= true
        attributes.byline ?= true
        attributes.portrait ?= true
        attributes.color ?= '#FFFFFF'

        """
        <iframe src="http://player.vimeo.com/video/#{attributes.id}?title=#{attributes.title}&amp;byline=#{attributes.byline}&amp;portrait=#{attributes.portrait}&amp;color=#{attributes.color}" width="#{attributes.width}" height="#{attributes.height}" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe> 
        """


module.exports = (BasePlugin) ->
    
    class Shortcodes extends BasePlugin

        name: 'shortcodes'

        config: 
            extension: 'sc'
            codes: defaults

        render: (opts, next) ->
            {inExtension,outExtension} = opts
            if inExtension is @config.extension # and (outExtension in ['js','css']) is false
                @renderShortcodes(opts, next)

            else
                return next()

        renderShortcodes: (opts, next) ->
            {templateData,content} = opts

            for code in @config.codes 
                findCode = new RegExp '\\[' + code.name + '(.*=\".*\")?\\](.*\\[\/' + code.name + '\])?', 'g'

                replacer = (match, attribstr, content) ->
                    # create attribute dictionary
                    attributes = {}

                    for entry in attribstr.split ' '
                        offset = entry.indexOf('=')
                        key = entry.substring(0, offset)
                        value = entry.substring(offset + 1)
                        value = value.replace /"/g, ''
                        attributes[key] = value if key != ""

                    # strip closing tag off content if exists
                    content = content.substring(0, content.lastIndexOf('[/')) if content?

                    # run shortcode replacer function
                    code.replacer(attributes, content)

                content = content.replace findCode, replacer

            opts.content = content

            # done
            next()