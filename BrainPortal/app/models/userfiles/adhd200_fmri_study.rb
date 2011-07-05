
#
# CBRAIN Project
#
# Study model based on the ADHD structure.
#
# $Id$
#

# This class represents a FileCollection meant to model a fMRI study
# structured according to the conventions used by ADHD.
class Adhd200FmriStudy < FmriStudy

  Revision_info=CbrainFileRevision[__FILE__]

  def self.pretty_type #:nodoc:
    "ADHD-200 fMRI Study"
  end

  def list_subjects(options = {}) #:nodoc:
    subs      = all_subjects
    filt_sess = looked_for(options[:sessions])
    return subs if filt_sess.size == 0
    subs.select do |sub|
      sesslist = all_sessions_for_subject(sub)
      sesslist.detect { |sess| filt_sess[sess] }
    end
  end

  def list_sessions(options = {}) #:nodoc:
    subs      = all_subjects
    filt_subs = looked_for(options[:subjects])
    sess_final = {}
    subs.each do |sub|
      next if filt_subs.size > 0 && ! filt_subs[sub]
      sesslist = all_sessions_for_subject(sub)
      sesslist.each { |sess| sess_final[sess] = true }
    end
    sess_final.keys.sort
  end

  def list_anat_files(options = {}) #:nodoc:
    subs       = all_subjects
    filt_subs  = looked_for(options[:subjects])
    filt_sess  = looked_for(options[:sessions])
    filt_state = looked_for(options[:states])
    results    = []
    subs.each do |sub|
      next if filt_subs.size > 0 && ! filt_subs[sub]
      sesslist = list_sessions( :subject => sub )
      sesslist = sesslist & filt_sess.keys if ! filt_sess.empty?
      next if sesslist.empty?
      sesslist.each do |session|
        statelist = list_files("#{sub}/#{session}", :directory).map { |e| Pathname.new(e.name).basename.to_s }
        statelist.each do |state|
          next unless state =~ /^anat/
          anatlist  = list_files("#{sub}/#{session}/#{state}", :regular).map { |e| Pathname.new(e.name).basename.to_s }
          if (! options[:ext].blank?) && options[:ext].is_a?(Regexp)
            anatlist = anatlist.select { |scan| scan.match(options[:ext]) }
          end
          anatlist.each { |scan| results << "#{sub}/#{session}/#{state}/#{scan}" }
        end
      end
    end
    results
  end

  def list_scan_files(options = {}) #:nodoc:
    subs       = all_subjects
    filt_subs  = looked_for(options[:subjects])
    filt_sess  = looked_for(options[:sessions])
    filt_state = looked_for(options[:states])
    results    = []
    subs.each do |sub|
      next if filt_subs.size > 0 && ! filt_subs[sub]
      sesslist = list_sessions( :subject => sub )
      sesslist = sesslist & filt_sess.keys if ! filt_sess.empty?
      next if sesslist.empty?
      sesslist.each do |session|
        statelist = list_files("#{sub}/#{session}", :directory).map { |e| Pathname.new(e.name).basename.to_s }
        statelist.each do |state|
          next if state =~ /^anat/
          next if filt_state.size > 0 && ! filt_state[state]
          anatlist  = list_files("#{sub}/#{session}/#{state}", :regular).map { |e| Pathname.new(e.name).basename.to_s }
          if (! options[:ext].blank?) && options[:ext].is_a?(Regexp)
            anatlist = anatlist.select { |scan| scan.match(options[:ext]) }
          end
          anatlist.each { |scan| results << "#{sub}/#{session}/#{state}/#{scan}" }
        end
      end
    end
    results
  end

  private

  def all_subjects #:nodoc:
    @_fmri_all_subjects ||= list_files(:top, :directory).map { |e| Pathname.new(e.name).basename.to_s }.reject { |n| n =~ /^(PDF)$/i }
  end

  def all_sessions_for_subject(subject) #:nodoc:
    list_files("#{subject}", :directory).map { |e| Pathname.new(e.name).basename.to_s }
  end

  # Returns a quick hash for looking up if an element
  # is in array_or_elem (or is elem itself).
  def looked_for(array_or_elem) #:nodoc:
    return {} unless array_or_elem
    array_or_elem = [ array_or_elem ] unless array_or_elem.is_a?(Array)
    array_or_elem.index_by { |x| x }
  end

end

