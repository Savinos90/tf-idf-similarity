module TfIdfSimilarity
  class Model
    include MatrixMethods

    extend Forwardable
    def_delegators :@model, :documents, :terms, :document_count

    # @param [Array<Document>] documents documents
    # @param [Hash] opts optional arguments
    # @option opts [Symbol] :library :gsl, :narray, :nmatrix or :matrix (default)
    def initialize(documents, opts = {})
      @model = TermCountModel.new(documents, opts)
      @library = (opts[:library] || :matrix).to_sym
      
      array = Array.new(terms.size) do |i|
        idf = inverse_document_frequency(terms[i])
        Array.new(documents.size) do |j|
          term_frequency(documents[j], terms[i]) * idf
        end
      end

      @matrix = initialize_matrix(array)
    end

    def keywords(document_id)
      keywords_array = []
      @matrix[document_id,true].sort_index.to_a.last(6).each { |t|
        keywords_array << @model.terms[t]
      }
      return keywords_array
    end

    # @param [Integer] index of first document to be merged
    # @param [Integer] index of second document to be merger
    # merge two documents and update the model
    def merge_and_update(first_index, second_index)

      if first_index == second_index
        return null
      end
      # merge two documents to the the document with smaller index στο term and count
      @model.documents[first_index].merge(@model.documents[second_index])
      @model.documents.delete_at(second_index)
      
      # update matrix του term and counts
      @model.merge_and_update_matrix(first_index, second_index)

      
      # update matrix στο model (float)
      @matrix[first_index,true] += @matrix[second_index,true]
      @matrix = @matrix.delete_at([second_index])
      
      return self
    end

    # Return the term frequency–inverse document frequency.
    #
    # @param [Document] document a document
    # @param [String] term a term
    # @return [Float] the term frequency–inverse document frequency
    def term_frequency_inverse_document_frequency(document, term)
      inverse_document_frequency(term) * term_frequency(document, term)
    end
    alias_method :tfidf, :term_frequency_inverse_document_frequency

    # Returns a similarity matrix for the documents in the corpus.
    #
    # @return [GSL::Matrix,NMatrix,Matrix] a similarity matrix
    # @note Columns are normalized to unit vectors, so we can calculate the cosine
    #   similarity of all document vectors.
    def similarity_matrix
      if documents.empty?
        []
      else
        multiply_self(normalize)
      end
    end

    # Return the index of the document in the corpus.
    #
    # @param [Document] document a document
    # @return [Integer,nil] the index of the document
    def document_index(document)
      @model.documents.index(document)
    end

    # Return the index of the document with matching text.
    #
    # @param [String] text a text
    # @return [Integer,nil] the index of the document
    def text_index(text)
      @model.documents.index do |document|
        document.text == text
      end
    end
  end
end
