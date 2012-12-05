
root = File.expand_path(File.dirname(File.dirname(__FILE__)))
$yamls = %w{ environment.yml checks.yml }.map { |x| File.join(root,'config',x)}

$check_keys = %w{ namespace class function operator rag}.map(&:to_sym) 

$config_dir = File.dirname(File.dirname(__FILE__)) + '/config'

require 'yaml'

describe "Configuration" do 
  
  context 'file' do 
    
    $yamls.each do |file|
      context file do 
        it "should exist" do 
          File.exists?(file).should be true
        end
        
        it "should be parseable" do
          expect { YAML.load_file file}.to_not raise_error
        end
      end
    end
  end

  context 'syntax' do
    $yamls.each do |file|
      context file do 
      end
    end
  end

  context 'data' do
    
    before {  @environment = YAML.load_file $yamls.first }
    subject {  @environment }

    #
    # Environment data
    # =================================
    context $yamls.first do 
      
      context :nagios do 
        
        it "should exist" do 
          @environment.should have_key :nagios
        end

        context :config do 

          before  {  @nagios = @environment[:nagios] }
          subject {  @nagios }

          it "should have :hostgroups key" do 
            @nagios.should have_key :hostgroups
          end
          
          context :erb do 

            it "should have key" do 
              @nagios.should have_key :erb
            end

            context 'file' do 
              it "should exist" do 
                File.exist?("#{$config_dir}/#{@nagios[:erb]}").should be true
              end
          end
        end


        context :api do 
          it "should have key" do 
              @nagios.should have_key :api
          end

          context "should have keys" do

            it :hostname do 
              @nagios[:api].should have_key :hostname
            end

            it :port do 
              @nagios[:api].should have_key :port
            end

          end
        end
        end
        
      end # :nagios
      
      # ========================================
      context :buckets do
        
        it "should exist" do
          @environment.should have_key :buckets
        end

        context :config do
          before { @buckets = @environment[:buckets]}

          it "should have: list or source" do 
            ([:source, :list] & @buckets.keys).should_not be_empty
          end

          it "should have only list or source" do 
            ([:source, :list] & @buckets.keys).length.should be 1
          end


          it do 
            case @buckets.keys.first
            when :source
              @buckets[:source].should be_a_kind_of String
            when :list 
              @buckets[:list].should be_a_kind_of Array

            end
          end
        end 
      end
    end
    
    
    #
    # Nagios checks
    # =================================
    context $yamls[1] do

      before  {  @config = YAML.load_file $yamls[1] }
      subject {  @config }
      
      it "should have checks"do
        @config.should have_key 'checks'
      end

      it do
        @config['checks'].should be_a_kind_of Hash
      end

      context 'check' do
        
        # Collect all values of checks by key
        def by_key key
          @checks.each_value.map { |x| x[key] }.flatten.uniq
        end
        
        # Collect all values of checks by method name
        def by_method meth
          @checks.each_value.map(&meth).flatten.uniq
        end

        before { 
          @checks = @config['checks']
        }

        it "name should be a Symbol" do 
          
          @checks.keys.map(&:class).uniq.should eq [Symbol]
        end

        it "should be a Hash" do
          by_method(:class).should eq [Hash]
        end
        
        it "should have all keys #{$check_keys.inspect}" do 
          by_method(:keys).should eq $check_keys
        end

        context "data types" do 


          context :namespace do 
            it do 
              by_key(:namespace).each do |s|
                s.should be_a String
              end
            end

            it 'should look like a Module' do 
              by_key(:namespace).each do |s|
                s.should =~ /(([A-Z]\w)::)*([A-Z]\w)/
              end
            end
          end

          context :class do 
            it do 
              by_key(:namespace).each do |s|
                s.should be_a String
              end
            end

            it 'should look like a Class' do 
              by_key(:namespace).each do |s|
                s.should =~ /([A-Z]\w)/
              end
            end
          end

          context :function do 
            it do 
              by_key(:function).each do |x|
                x.should be_a Symbol
              end
            end
          end

          context :operator do
            it 'should be Symbol or Array' do 
              by_key(:operator).each do |o|
                [Symbol, Array].should include o.class
              end
              
            end
            
            context Array do 
              it 'should have 3 elements' do
                next
                pending
              end
            end
          end

          context :rag do 
            it 'should be Array' do 
              pending
            end

            it 'should have 3 elements' do 
              pending
            end
          end

          
        end
        
        # Check that all modules and classes in the namespace
        # configuration exist
        context 'classes' do
          before { 
            require_relative '../lib/couchbase' 
            @defaults = { 
              :hostname => 'localhost',
              :bucket => 'default'
            }
          }
          
          it do 
            @checks.each_value.map { |x| "#{x[:namespace]}::#{x[:class]}".to_class }.uniq.each do |c|
              expect { c.new @defaults }.to_not raise_error
            end
          end

#
# TODO: Not here. Methods need actual connection to get data
# ==============================================================          
#           # Check that all configred checks have method to fetch data
#           context 'methods' do 
#             it do 
#               @checks.each do |meth,v|
#                 expect { "#{v[:namespace]}::#{v[:class]}".to_class.new(@defaults).send(meth) }.to_not raise_error
#               end
#             end
#           end

        end

      end
    end
  end
  
end
