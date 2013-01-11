
root = File.expand_path(File.dirname(File.dirname(__FILE__)))
$config_dir = "#{root}/config"
#
# Check these files. Do not change order, add new files at the end.
#
YAMLS = %w{ environment.yml checks.yml }.map { |x| File.join(root,'config',x)}

CHECK_KEYS = %w{ only_if namespace class function operator rag}.map(&:to_sym) 


require 'yaml'

describe "Configuration" do 
  
  context 'file' do 
    
    
    YAMLS.each do |file|
      context file do 

        it { File.should exist(file) }
        
        it "should be YAML" do
          expect { YAML.load_file file}.to_not raise_error
        end
      end
    end
  end

  context 'syntax' do
    
    before {  @environment = YAML.load_file YAMLS.first }
    subject {  @environment }

    #
    # Environment data
    # =================================
    context File.basename YAMLS[0] do 
      
      subject {  @environment }

      it { should have_key :nagios } 

      context :nagios do 
        before  {  @nagios = @environment[:nagios] }
        subject {  @nagios }
        
        it { should have_key :hostgroups }
        it { should have_key :erb } 
        
        context :erb do 
          it { File.should exist("#{$config_dir}/#{@nagios[:erb]}") }
        end

        it { should have_key :api }

        context :api do 
          subject {  @api = @nagios[:api] }

          it { should have_key :hostname }
          it { should have_key :port }

        end
      end # :nagios
      
      # ========================================
      it { should have_key :buckets }
      context :buckets do
        before { @buckets = @environment[:buckets]}

        it "should have keys :list or :source" do 
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
    
    
    #
    # Nagios checks
    # =================================
    context File.basename YAMLS[1] do

      before  {  @config = YAML.load_file YAMLS[1] }
      subject {  @config }
      
      it { should have_key 'checks' }
      it { @config['checks'].should be_a_kind_of Hash }

      context 'check' do
        before { @checks = @config['checks'] }
        subject {  @checks }
        
        # Collect all values of checks by key
        def by_key key
          @checks.each_value.map { |x| x[key] }.uniq
        end
        
        # Collect all values of checks by method name
        def by_method meth
          @checks.each_value.map(&meth).uniq
        end

        it "name should be a Symbol" do 
          @checks.keys.map(&:class).uniq.should eq [Symbol]
        end

        it "should be a Hash" do
          by_method(:class).should eq [Hash]
        end

        it 'Hash keys should be Symbols' do 
          by_method(:keys).flatten.map(&:class).uniq.should eq [Symbol]
        end
        
        
        it "should have all keys #{CHECK_KEYS.inspect}" do 
          by_method(:keys).flatten.uniq.sort.should eq CHECK_KEYS.sort
        end

        context :namespace do 

          it { by_key(:namespace).each { |s| s.should be_a String }}

          it 'should look like a Module' do
            by_key(:namespace).each do |s|
              s.should =~ /^[A-Z]\w+(::[A-Z]\w+)*$/
            end
          end
        end

        describe :class do 

          before { @classes = by_key(:class) }

          it { @classes.each { |s| s.should be_a String }}

          it 'should look like a Class' do 
            @classes.each do |s|
              s.should =~ /^[A-Z]\w+$/
            end
          end
        end

        context :function do 

          it { by_key(:function).each { |x| x.should be_a Symbol } }

        end

        context :operator do
          before { @operators = by_key(:operator) }

          it 'should be Symbol or Array' do 
            @operators.each do |o|
              [Symbol, Array].should include o.class
            end
          end
          
          context Array do 

            it 'should have 3 elements' do
              @operators.each do |op|
                op.length.should == 3 if op.is_a? Array
              end
            end

          end
        end

        context :rag do
          before {  @rags = by_key(:rag) }

          it { @rags.map(&:class).should be_an Array } 

          it 'should have 3 elements' do 
            @rags.map(&:length).uniq.should == [3]
          end
        end

        
        # Check that all modules and classes in the namespace
        # configuration exist
        context 'classes' do
          before { 
            require_relative '../lib/couchbase' 
            @defaults = { hostname: 'localhost', bucket: 'default' }
          }
          
          it {
            @checks.each_value.map { |x| "#{x[:namespace]}::#{x[:class]}".to_class }.uniq.each do |c|
              expect { c.new @defaults }.to_not raise_error
            end
          }

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
