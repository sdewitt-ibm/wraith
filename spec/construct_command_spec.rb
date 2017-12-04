require "_helpers"

describe "Wraith config to CLI argument mapping" do
  describe "passing variables to construct_command" do
    # set default variables we can override if necessary
    let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
    let(:saving)      { Wraith::SaveImages.new(config_name) }
    let(:width)       { 320 }
    let(:url)         { "http://example.com/my-page" }
    let(:file_name)   { "wraith/my-page/320_phantomjs_latest.png" }
    let(:selector)    { ".my_selector" }
    let(:global_bc)   { "javascript/before_capture.js" }
    let(:path_bc)     { false }
    let(:global_bo)   { "javascript/before_open.js" }
    let(:path_bo)     { false }

    it "should take a load of variables and construct a command" do
      expected = "phantomjs  '#{Dir.pwd}/lib/wraith/javascript/phantom.js' 'http://example.com/my-page' '320' 'wraith/my-page/320_phantomjs_latest.png' '.my_selector' '#{Dir.pwd}/javascript/before_capture.js' 'false' '#{Dir.pwd}/javascript/before_open.js' 'false'"
      actual   = saving.construct_command(width, url, file_name, selector, global_bc, path_bc, global_bo, path_bo)
      expect(actual).to eq expected
    end

    it "should allow hashtags in selectors" do
      selector = '#some-id'
      expected = "phantomjs  '#{Dir.pwd}/lib/wraith/javascript/phantom.js' 'http://example.com/my-page' '320' 'wraith/my-page/320_phantomjs_latest.png' '\\#some-id' '#{Dir.pwd}/javascript/before_capture.js' 'false' '#{Dir.pwd}/javascript/before_open.js' 'false'"
      actual   = saving.construct_command(width, url, file_name, selector, global_bc, path_bc, global_bo, path_bo)
      expect(actual).to eq expected
    end

    it "should be able to pass multiple widths at once" do
      width    = [320, 624, 976]
      expected = "phantomjs  '#{Dir.pwd}/lib/wraith/javascript/phantom.js' 'http://example.com/my-page' '320,624,976' 'wraith/my-page/320_phantomjs_latest.png' '.my_selector' '#{Dir.pwd}/javascript/before_capture.js' 'false' '#{Dir.pwd}/javascript/before_open.js' 'false'"
      actual   = saving.construct_command(width, url, file_name, selector, global_bc, path_bc, global_bo, path_bo)
      expect(actual).to eq expected
    end

    it "should call casperjs when the config says so" do
      config_name = get_path_relative_to(__FILE__, "./configs/test_config--casper.yaml")
      saving      = Wraith::SaveImages.new(config_name)
      expected    = "casperjs  '#{Dir.pwd}/spec/js/custom_snap_file.js' 'http://example.com/my-page' '320' 'wraith/my-page/320_phantomjs_latest.png' '.my_selector' '#{Dir.pwd}/javascript/before_capture.js' 'false' '#{Dir.pwd}/javascript/before_open.js' 'false'"
      actual      = saving.construct_command(width, url, file_name, selector, global_bc, path_bc, global_bo, path_bo)
      expect(actual).to eq expected
    end
  end
end
