require File.dirname(__FILE__) + '/../spec_helper'

describe EasyTranslate::Translation do

  it 'should return a single if given a single - from doc' do
    EasyTranslate::Translation::TranslationRequest.stub!(:new).and_return(OpenStruct.new({
      :perform_raw => '{"data":{"translations":[{"translatedText":"Hallo Welt"}]}}',
      :multi? => false
    }))
    trans = EasyTranslate.translate 'Hello world', :target => 'de'
    trans.should == 'Hallo Welt'
  end

  it 'should return a multiple if given multiple - from doc' do
    EasyTranslate::Translation::TranslationRequest.stub!(:new).and_return(OpenStruct.new({
      :perform_raw => '{"data":{"translations":[{"translatedText": "Hallo Welt"},{"translatedText":"Mein Name ist Jeff"}]}}',
      :multi? => true
    }))
    trans = EasyTranslate.translate ['Hello world', 'my name is jeff'], :target => 'de'
    trans.should == ['Hallo Welt', 'Mein Name ist Jeff']
  end

  klass = EasyTranslate::Translation::TranslationRequest
  describe klass do

    describe :path do
      
      it 'should have a valid path' do
        request = klass.new('abc', :target => 'en')
        request.path.should_not be_empty
      end

    end

    describe :initialize do

      it 'should raise an error when there is no target given' do
        lambda do
          req = klass.new('abc', :source => 'en')
        end.should raise_error ArgumentError
      end

    end

    describe :params do

      it 'should include source in params if given' do
        req = klass.new('abc', :source => 'en', :target => 'es')
        req.params[:source].should == 'en'
      end

      it 'should not include source by default' do
        req = klass.new('abc', :target => 'es')
        req.params[:source].should be_nil
      end

      it 'should include target' do
        req = klass.new('abc', :target => 'es')
        req.params[:target].should == 'es'
      end

      it 'should not include format by default' do
        req = klass.new('abc', :target => 'es')
        req.params[:format].should be_nil
      end

      it 'should not include format when given as false' do
        req = klass.new('abc', :html => false, :target => 'es')
        req.params[:format].should be_nil
      end

      it 'should include format when html is true' do
        req = klass.new('abc', :html => true, :target => 'es')
        req.params[:format].should == 'html'
      end

      it 'should use default params' do
        EasyTranslate.api_key = 'abc'
        request = klass.new('abc', :target => 'es')
        request.params[:key].should == 'abc'
      end

      it 'should allow overriding of params' do
        EasyTranslate.api_key = 'abc'
        request = klass.new('abc', :key => 'def', :target => 'es')
        request.params[:key].should == 'def'
      end

      it 'should allow overriding of key as api_key' do
        EasyTranslate.api_key = 'abc'
        request = klass.new('abc', :api_key => 'def', :target => 'es')
        request.params[:key].should == 'def'
        request.params[:api_key].should be_nil
      end

    end

    describe :multi? do

      it 'should be true if multiple are passed' do
        request = klass.new(['abc', 'def'], :target => 'es')
        request.should be_multi
      end

      it 'should be true if one is passed, but in an array' do
        request = klass.new(['abc'], :target => 'es')
        request.should be_multi
      end

      it 'should be true if one is passed as a string' do
        request = klass.new('abc', :target => 'es')
        request.should_not be_multi
      end

    end

    describe :body do

      it 'should insert the texts into the body' do
        request = klass.new(['abc', 'def'], :target => 'es')
        request.body.should == 'q=abc&q=def'
      end

      it 'should insert the text into the body' do
        request = klass.new('abc', :target => 'es')
        request.body.should == 'q=abc'
      end

      it 'should URI escape the body' do
        request = klass.new('%', :target => 'es')
        request.body.should == 'q=%25'
      end

    end

  end

end
