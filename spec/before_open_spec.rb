require "_helpers"
require "image_size"

def run_js_then_capture(config)
  saving     = Wraith::SaveImages.new(config_name)
  generated_image = "shots/test/temporary_jsified_image.png"
  capture_image   = saving.construct_command('320x16', "http://www.bbc.com/afrique", generated_image, selector, false, false, config[:global_open_js], config[:path_open_js])
  `#{capture_image}`
  Wraith::CompareImages.new(config_name).compare_task(generated_image, config[:output_should_look_like], "shots/test/test_diff.png", "shots/test/test.txt")
  diff = File.open("shots/test/test.txt", "rb").read
  expect(diff).to eq "0.0"
end

describe Wraith do
  let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--casper.yaml" }
  let(:wraith) { Wraith::Wraith.new(config_name) }
  let(:selector) { "body" }

  before(:each) do
    Wraith::FolderManager.new(config_name).clear_shots_folder
    Dir.mkdir("shots/test")
  end

  describe "different ways of determining the before_open file" do
    it "should allow users to specify the relative path to the before_open file" do
      config = YAML.load '
        browser:        casperjs
        before_capture: javascript/do_something_open.js
      '
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      # not sure about having code IN the test, but we want to get this right.
      expect(wraith.before_capture).to eq(Dir.pwd + "/javascript/do_something_open.js")
    end

    it "should allow users to specify the absolute path to the before_open file" do
      config = YAML.load '
        browser:        casperjs
        before_capture: /Users/some_user/wraith/javascript/do_something_open.js
      '
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.before_capture).to eq("/Users/some_user/wraith/javascript/do_something_open.js")
    end
  end

  #  @TODO - uncomment and figure out why broken
  describe "When hooking into before_capture (PhantomJS)" do
     let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
     let(:saving) { Wraith::SaveImages.new(config_name) }
     let(:wraith) { Wraith::Wraith.new(config_name) }
     let(:selector) { "body" }
     let(:before_open_global_js) { "spec/js/global--open.js" }
     let(:before_open_path_js) { "spec/js/path--open.js" }

     it "Executes the global JS before opening" do
       run_js_then_capture(
         global_open_js: before_open_global_js,
         path_open_js:   false,
         output_should_look_like: 'spec/base/global.png',
         engine:    'phantomjs'
       )
     end

     it "Executes the path-level JS before capturing" do
       run_js_then_capture(
         global_open_js: false,
         path_open_js: before_open_path_js,
         output_should_look_like: 'spec/base/path.png',
         engine:    'phantomjs'
       )
     end

     it "Executes the global JS before the path-level JS" do
       run_js_then_capture(
         global_open_js: before_open_global_js,
         path_open_js: before_open_path_js,
         output_should_look_like: 'spec/base/path.png',
         engine:    'phantomjs'
       )
     end
  end
end
