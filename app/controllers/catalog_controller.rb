# frozen_string_literal: true
class CatalogController < ApplicationController

  include BlacklightRangeLimit::ControllerOverride

  include Blacklight::Catalog
  include Blacklight::Marc::Catalog


  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      :qt => 'select',
      rows: 10
    }

    config.default_document_solr_params = {
        :qt => 'document',
        :fl => '*',
        :rows => 1,
        :q => '{!raw f=id v=$id}'
    }

    config.per_page = [10, 20, 50] # [10,20,50,100]
    config.default_per_page = 20 # the first per_page value, or the value given here

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1
    #  # q: '{!term f=id v=$id}'
    #}

    config.index.thumbnail_field = :thumbnail

    # solr field configuration for search results/index views
    config.index.title_field = 'title'
    config.index.display_type_field = 'level'
    config.index.partials = [:index_header, :index_thumbnail, :index]

    config.show.title_field = 'title'
    config.show.display_type_field = 'record_origin'
    config.show.partials = [:show_header, :show_thumbnail, :show]

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'collection_pivot_field', label: 'Data Providers', :pivot => ['data_provider_facet', 'collection_facet']
    config.add_facet_field 'level_facet', label: 'Level'
    config.add_facet_field 'contributor_facet', label: 'Contributor', limit: 10
    config.add_facet_field 'subject_facet', label: 'Subject', limit: 10, index_range: 'A'..'Z'
    config.add_facet_field 'language_facet', label: 'Language', limit: 10
    config.add_facet_field 'coverage_facet', label: 'Coverage', limit: 10
    config.add_facet_field 'date_created_facet', label: 'Date of Creation', range: true

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title', label: 'Title'
    config.add_index_field 'collection', label: 'Part of collection'
    config.add_index_field 'data_provider', label: 'Data Provider'
    config.add_index_field 'date_created', label: 'Date of Creation'
    config.add_index_field 'level', label: 'Level'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'collection', label: 'Part of collection', :link_to_search => :collection_facet
    config.add_show_field 'title', label: 'Title'
    config.add_show_field 'subtitle', label: 'Subtitle'
    config.add_show_field 'level', label: 'Level', :link_to_search => :level_facet
    config.add_show_field 'contributor', label: 'Contributor', :link_to_search => :contributor_facet
    config.add_show_field 'extent', label: 'Extent'
    config.add_show_field 'coverage', label: 'Coverage'
    config.add_show_field 'temporal_coverage', label: 'Temporal Coverage'
    config.add_show_field 'date_created', label: 'Date of Creation'
    config.add_show_field 'language', label: 'Language', :link_to_search => :language_facet
    config.add_show_field 'publisher', label: 'Publisher'
    config.add_show_field 'data_provider', label: 'Data Provider'
    config.add_show_field 'provenance', label: 'Provenance'
    config.add_show_field 'type', label: 'Type'
    config.add_show_field 'description', label: 'Description', helper_method: 'act_as_html'
    config.add_show_field 'subject', label: 'Subject', :link_to_search => :subject_facet
    config.add_show_field 'is_shown_at', label: 'Shown At', helper_method: 'act_as_link'
    config.add_show_field 'is_shown_by', label: 'Shown By', helper_method: 'act_as_link'
    config.add_show_field 'rights', label: 'Rights', helper_method: 'act_as_link'
    config.add_show_field 'is_part_of', label: 'Part of', helper_method: 'act_as_link'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'All Fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        qf: '$qf_title',
        pf: '$pf_title'
      }
    end

    config.add_search_field('description') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'description' }
      field.solr_local_parameters = {
        qf: '$qf_description',
        pf: '$pf_description'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.solr_local_parameters = {
        qf: '$qf_subject',
        pf: '$pf_subject'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', label: 'relevance'
    config.add_sort_field 'title_sort asc, score desc', label: 'title'
    config.add_sort_field 'date_created_sort desc, score desc', label: 'date'


    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end
end
