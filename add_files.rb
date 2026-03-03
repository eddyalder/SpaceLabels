require 'xcodeproj'

project_path = '/Users/edalder/Documents/CodeWorkspace/SpaceLabelsV2/SpaceLabelsV2.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
group = project.main_group.find_subpath('SpaceLabelsV2', true)

files_to_add = [
  'SpacesManager.swift',
  'NotchUI.swift',
  'CarouselUI.swift',
  'WindowControllers.swift',
  'SettingsUI.swift'
]

files_to_add.each do |file|
  file_path = "/Users/edalder/Documents/CodeWorkspace/SpaceLabelsV2/SpaceLabelsV2/#{file}"
  # Check if already added
  unless group.files.any? { |f| f.path == file }
    file_ref = group.new_reference(file_path)
    target.add_file_references([file_ref])
  end
end

project.save