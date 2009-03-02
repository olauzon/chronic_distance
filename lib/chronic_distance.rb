require 'numerizer'

module ChronicDistance
  
  extend self
  
  # Given a string representation of distance,
  # return an integer (or float) representation
  # of the distance in millimeters. Accepts an options
  # hash with :round => true as an option.
  def parse(string, options = {})
    result = calculate_from_words(cleanup(string))
    result = result.round.to_i if options[:round]
    result == 0 ? nil : result
  end
  
  # Given an integer or float distance in millimeters,
  # and an optional format and unit,
  # return a formatted string representing distance
  def output(millimeters, options = {})
    options[:unit]   ||= 'millimeters'
    options[:format] ||= :default
    
    unit_options      = unit_formatting_options[options[:format]]
    options[:format]  = :short if options[:format] == :default
    unit              = unit_format(options[:unit], options[:format])
    
    result = humanize_distance(
                                distance_in_unit(millimeters, options[:unit]),
                                unit,
                                unit_options[:pluralize],
                                unit_options[:spacer]
                              )
    
    result.length == 0 ? nil : result
  end
  
private
  
  def distance_in_unit(millimeters, unit)
    number = (millimeters.to_f / millimeter_multiplier(unit))
    number = number.round if number == number.round
    number
  end
  
  def distance_units
    [
      'millimeters' ,
      'centimeters' ,
      'meters'      ,
      'kilometers'  ,
      'inches'      ,
      'feet'        ,
      'yards'       ,
      'miles'
    ]
  end
  
  def millimeter_multiplier(unit = 'millimeters')
    return 0 unless distance_units.include?(unit)
    case unit
      when 'millimeters'  ;             1
      when 'centimeters'  ;            10
      when 'meters'       ;         1_000
      when 'kilometers'   ;     1_000_000
      when 'inches'       ;            25.4
      when 'feet'         ;           304.8
      when 'yards'        ;           914.4
      when 'miles'        ;     1_609_344
    end
  end
  
  def calculate_from_words(string)
    distance = 0
    words = string.split(' ')
    words.each_with_index do |value, key|
      if value =~ float_matcher
        distance += (
                      convert_to_number(value) *
                      millimeter_multiplier(words[key + 1])
                    )
      end
    end
    distance
  end
  
  def humanize_distance(number, unit, pluralize, spacer = '')
    return '' if number == 0
    display_unit = ''
    display_unit << unit
    if !(number == 1) && pluralize
      if unit == 'inch'
        display_unit = 'inches'
      elsif unit == 'foot'
        display_unit = 'feet'
      else
        display_unit << 's'
      end
    end
    
    result = "#{number}#{spacer}#{display_unit}"
    result
  end
  
  def cleanup(string)
    result = Numerizer.numerize(string)
    result = result.gsub(float_matcher) {|n| " #{n} "}.squeeze(' ').strip
    result = filter_through_white_list(result)
  end
  
  def convert_to_number(string)
    string.to_f % 1 > 0 ? string.to_f : string.to_i
  end
  
  def float_matcher
    /[0-9]*\.?[0-9]+/
  end
  
  # Get rid of unknown words and map found
  # words to defined distance units
  def filter_through_white_list(string)
    result = Array.new
    string.split(' ').each do |word|
      if word =~ float_matcher
        result << word.strip
        next
      end
      result << mappings[word.strip] if mappings.has_key?(word.strip)
    end
    result.join(' ')
  end
  
  def mappings
    maps = Hash.new
    mappings_by_format.values.each do |format_mappings|
      maps.merge!(format_mappings)
    end
    maps
  end
  
  def unit_format(unit, format = :short)
    formats = Hash.new
    mappings_by_format[format].each do |k, v|
      formats[v] = k
    end
    formats[unit]
  end
  
  def unit_formatting_options
    {
      :default => {
        :spacer     => ' ',
        :pluralize  => false
      },
      
      :short => {
        :spacer     => '',
        :pluralize  => false
      },
      
      :long => {
        :spacer     => ' ',
        :pluralize  => true
      }
    }
  end
  
  def mappings_by_format
    {
      :short => {
        'mm'                => 'millimeters',
        'cm'                => 'centimeters',
        'm'                 => 'meters',
        'km'                => 'kilometers',
        '"'                 => 'inches',
        '\''                => 'feet',
        'yd'                => 'yards',
        'mile'              => 'miles'
      },
      
      :long => {
        'millimeter'        => 'millimeters',
        'centimeter'        => 'centimeters',
        'meter'             => 'meters',
        'kilometer'         => 'kilometers',
        'inch'              => 'inches',
        'foot'              => 'feet',
        'yard'              => 'yards',
        'mile'              => 'miles'
      },
      
      :other => {
        'mms'               => 'millimeters',
        'millimeters'       => 'millimeters',
        'cms'               => 'centimeters',
        'centimeters'       => 'centimeters',
        'ms'                => 'meters',
        'meters'            => 'meters',
        'k'                 => 'kilometers',
        'ks'                => 'kilometers',
        'kms'               => 'kilometers',
        'kilometers'        => 'kilometers',
        'inch'              => 'inches',
        'inches'            => 'inches',
        'ft'                => 'feet',
        'feet'              => 'feet',
        'y'                 => 'yards',
        'yds'               => 'yards',
        'yards'             => 'yards',
        'miles'             => 'miles'
      }
    }
  end
  
end