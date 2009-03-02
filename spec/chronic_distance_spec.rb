require File.dirname(__FILE__) + '/spec_helper'

describe ChronicDistance do
  
  describe '.parse' do
    
    @exemplars = {
      '1mm'                     =>  1   *  1,
      '5 mms'                   =>  5   *  1,
      'fifty millimeters'       =>  50  *  1,
      '1cm'                     =>  1   * 10,
      '2 cms'                   =>  2   * 10,
      '1 centimeter'            =>  1   * 10,
      '1m'                      =>  1   * 1_000,
      '2 ms'                    =>  2   * 1_000,
      '1 meter'                 =>  1   * 1_000,
      '1k'                      =>  1   * 1_000_000,
      '5 ks'                    =>  5   * 1_000_000,
      '1km'                     =>  1   * 1_000_000,
      '2 kms'                   =>  2   * 1_000_000,
      '1 kilometer'             =>  1   * 1_000_000,
      '4 kilometers'            =>  4   * 1_000_000,
      '1 inch'                  =>  1   *        25.4,
      '4 inches'                =>  4   *        25.4,
      '1 ft'                    =>  1   *       304.8,
      '1y'                      =>  1   *       914.4,
      'one yd'                  =>  1   *       914.4,
      'eight yds'               =>  8   *       914.4,
      '1 yard'                  =>  1   *       914.4,
      'forty yards'             =>  40  *       914.4,
      '1 mile'                  =>  1   * 1_609_344,
      '3.5 miles'               =>  3.5 * 1_609_344,
      '4 miles'                 =>  4   * 1_609_344,
      '4 kms 2 miles'           =>  4 * 1_000_000 + 2   * 1_609_344,
      'those four kms and 2 miles also' =>  4 * 1_000_000 + 2 * 1_609_344
    }
    
    it "should return nil if the string can't be parsed" do
      ChronicDistance.parse('gobblygoo').should be_nil
    end
    
    it "should return an integer if units are kilometers" do
      ChronicDistance.parse('4kms').is_a?(Integer).should be_true
    end
    
    it "should return an integer if units are miles" do
      ChronicDistance.parse('3 miles').is_a?(Integer).should be_true
    end
    
    it "should return a float if units are yards" do
      ChronicDistance.parse('4 yards').is_a?(Float).should be_true
    end
    
    it "should return an integer if units are yards and distance is rounded" do
      ChronicDistance.parse('four yards', :round => true).
      is_a?(Integer).should be_true
    end
    
    @exemplars.each do |key, value|
      
      it "should properly parse a distance like #{key}" do
        ChronicDistance.parse(key).should == value
      end
      
    end
    
  end
  
  describe '.output' do
    
    it "should return nil if the input can't be parsed" do
      ChronicDistance.parse('gobblygoo').should be_nil
    end
    
    @exemplars = {
      
      (1) => {
        
        'millimeters' => {
          :short    => '1mm',
          :default  => '1 mm',
          :long     => '1 millimeter'
        },
      },
      
      (1_609_344) => {
        
        'millimeters' => {
            :short    => '1609344mm',
            :default  => '1609344 mm',
            :long     => '1609344 millimeters'
        },
      },
      
      (1_609_344) => {
        
        'centimeters' => {
          :short    => '160934.4cm',
          :default  => '160934.4 cm',
          :long     => '160934.4 centimeters'
        },
      },
      
      (1_609_344) => {
        'miles' => {
          :short    => '1mile',
          :default  => '1 mile',
          :long     => '1 mile'
        }
      },
      
      (4 * 1_609_344) => {
      
        'miles' => {
          :short    => '4mile',
          :default  => '4 mile',
          :long     => '4 miles'
        }
      },
      
      (2.5 * 1_609_344) => {
      
        'miles' => {
          :short    => '2.5mile',
          :default  => '2.5 mile',
          :long     => '2.5 miles'
        }
      },
      
      (4 * 25.4) => {
        
        'inches' => {
          :short    => '4"',
          :default  => '4 "',
          :long     => '4 inches'
        }
      },
      
      (4 * 304.8) => {
        
        'feet' => {
          :short    => '4\'',
          :default  => '4 \'',
          :long     => '4 feet'
        }
      }
    }
    
    @exemplars.each do |distance, format|
      format.each do |unit, distance_format|
        distance_format.each do |format_option, formatted_distance|
          
          it "should output #{distance} millimeters as #{formatted_distance}
              using the #{format_option.to_s} #{unit} format" do
            ChronicDistance.output( distance,
                                    :format => format_option,
                                    :unit   => unit).
            should == formatted_distance
          end
          
        end
      end
    end
    
    it "should use the default format when the format is not specified" do
      ChronicDistance.output(2000).should == '2000 mm'
    end
    
  end
  
  describe " private methods" do
    
    describe ".calculate_from_words" do
      
      it "should return distance in millimeters" do
        ChronicDistance.
        instance_eval("calculate_from_words('10 centimeters')").
        should == 100
      end
      
      it "should return distance in millimeters when mixing input units" do
        ChronicDistance.
        instance_eval("calculate_from_words('2 kilometers and 10 centimeters')").
        should == 2_000_100
      end
      
      it "should return distance in millimeters when mixing input units" do
        ChronicDistance.
        instance_eval("calculate_from_words('2 miles and 10 centimeters')").
        should == 3_218_788
      end
      
    end
    
    describe ".cleanup" do
      
      it "should clean up extraneous words" do
        ChronicDistance.
        instance_eval("cleanup('4 meters and 10 centimeters')").
        should == '4 meters 10 centimeters'
      end
      
      it "should cleanup extraneous spaces" do
        ChronicDistance.
        instance_eval("cleanup('  4 meters and 11     centimeters')").
        should == '4 meters 11 centimeters'
      end
      
      it "should insert spaces where there aren't any" do
        ChronicDistance.
        instance_eval("cleanup('4m11.5cm')").
        should == '4 meters 11.5 centimeters'
      end
      
    end
    
    describe ".unit_format" do
      
      it "should select 'meter' for the long meters format" do
        ChronicDistance.
        instance_eval("unit_format('meters', :long)").
        should == 'meter'
      end
      
      it "should select 'm' for the short meters format" do
        ChronicDistance.
        instance_eval("unit_format('meters', :short)").
        should == 'm'
      end
      
      it "should select 'mm' for the short millimeters format" do
        ChronicDistance.
        instance_eval("unit_format('millimeters', :short)").
        should == 'mm'
      end
      
    end
    
  end
  
end