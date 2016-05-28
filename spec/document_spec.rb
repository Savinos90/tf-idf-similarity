require 'spec_helper'

# @see https://github.com/bbcrd/Similarity/blob/master/test/test_document.rb
module TfIdfSimilarity
  describe Document do
    let :text do
      "FOO-foo BAR bar \r\n\t 123 !@#"
    end
    
    let :second_text do
      "FOO-foo BAR ok ok \r\n\t 123 !@#"
    end


    let :tokens do
      ['FOO-foo', 'BAR', 'bar', "\r\n\t", '123', '!@#']
    end

    let :document_without_text do
      Document.new('')
    end

    let :document do
      Document.new(text)
    end

    let :document_with_id do
      Document.new(text, :id => 'baz')
    end

    let :document_with_tokens do
      Document.new(text, :tokens => tokens)
    end

    let :document_with_term_counts do
      Document.new(text, :term_counts => {'bar' => 5, 'baz' => 10})
    end

    let :document_with_term_counts_and_size do
      Document.new(text, :term_counts => {'bar' => 5, 'baz' => 10}, :size => 20)
    end

    let :document_with_term_counts_url_and_size do
      Document.new(text, :term_counts => {'bar' => 5, 'baz' => 10}, :size => 20, :urls => ["http://www.theguardian.com/lifeandstyle/2016/may/28/something-borrowed-rise-identikit-wedding"])
    end
    
    let :second_document_with_term_counts_url_and_size do
      Document.new(second_text, :term_counts => {'bar' => 2, 'baz' => 1, 'ok' => 2}, :size => 15, :urls => ["http://www.theguardian.com/environment/2016/may/28/sea-sponge-the-size-of-a-minivan-discovered-in-ocean-depths-off-hawaii"])
    end


    
    let :document_with_one_url do
      Document.new(text, :urls => ["http://www.theguardian.com/lifeandstyle/2016/may/28/something-borrowed-rise-identikit-wedding"])
    end

    let :document_with_many_url do
      Document.new(text, :urls => ["http://www.theguardian.com/lifeandstyle/2016/may/28/something-borrowed-rise-identikit-wedding","http://www.theguardian.com/environment/2016/may/28/sea-sponge-the-size-of-a-minivan-discovered-in-ocean-depths-off-hawaii"])
    end


    let :document_with_size do
      Document.new(text, :size => 10)
    end

    describe '#id' do
      it 'should return the ID if no ID given' do
        document.id.should == document.object_id
      end

      it 'should return the given ID' do
        document_with_id.id.should == 'baz'
      end
    end

    describe '#text' do
      it 'should return the text' do
        document.text.should == text
      end
    end

    describe '#size' do
      it 'should return the number of tokens if no tokens given' do
        document.size.should == 4
      end

      it 'should return the number of tokens if tokens given' do
        document_with_tokens.size.should == 3
      end

      it 'should return the number of tokens if no text given' do
        document_without_text.size.should == 0
      end

      it 'should return the number of tokens if term counts given' do
        document_with_term_counts.size.should == 15
      end

      it 'should return the given number of tokens if term counts and size given' do
        document_with_term_counts_and_size.size.should == 20
      end

      it 'should not return the given number of tokens if term counts not given' do
        document_with_size.size.should_not == 10
      end
    end

    describe '#term_counts' do
      it 'should return the term counts if no tokens given' do
        document.term_counts.should == {'foo' => 2, 'bar' => 2}
      end

      it 'should return the term counts if tokens given' do
        document_with_tokens.term_counts.should == {'foo-foo' => 1, 'bar' => 2}
      end

      it 'should return no term counts if no text given' do
        document_without_text.term_counts.should == {}
      end

      it 'should return the term counts if term counts given' do
        document_with_term_counts.term_counts.should == {'bar' => 5, 'baz' => 10}
      end
    end

    describe '#terms' do
      it 'should return the terms if no tokens given' do
        document.terms.sort.should == ['bar', 'foo']
      end

      it 'should return the terms if tokens given' do
        document_with_tokens.terms.sort.should == ['bar', 'foo-foo']
      end

      it 'should return no terms if no text given' do
        document_without_text.terms.should == []
      end

      it 'should return the terms if term counts given' do
        document_with_term_counts.terms.sort.should == ['bar', 'baz']
      end
    end

    describe '#term_count' do
      it 'should return the term count if no tokens given' do
        document.term_count('foo').should == 2
      end

      it 'should return the term count if tokens given' do
        document_with_tokens.term_count('foo-foo').should == 1
      end

      it 'should return no term count if no text given' do
        document_without_text.term_count('foo').should == 0
      end

      it 'should return the term count if term counts given' do
        document_with_term_counts.term_count('bar').should == 5
      end
    end

    describe '#urls_csv' do
      it 'should return 1 url if it refers to one article' do
        document_with_one_url.urls.length.should == 1
      end

      it 'should return two url if it refers to 2 article' do
        document_with_many_url.urls.length.should == 2
      end

    end

    describe '#+operator' do
      it 'θα πρέπει να προσθέσει τα άρθρα' do
        cluster = document_with_term_counts_url_and_size + second_document_with_term_counts_url_and_size
        cluster.term_counts.should == {'bar' => 7, 'baz' => 11, 'ok' => 2}
        cluster.size.should == 35
        cluster.urls.length.should == 2
      end
      
    end

    
  end
end
