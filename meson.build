# project name and programming language
project('com.github.darkoverlordofdata.catmenu', ['vala', 'c'], version: '0.0.1')


# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Add vapi files
add_project_arguments(
  [
    '--vapidir',
    join_paths(meson.current_source_dir(), 'vapi')
  ],
  language: 'vala'
)

# Set configuration data
conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('PREFIX', get_option('prefix'))
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PACKAGE', meson.project_name())
conf.set_quoted('LOCALE_DIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('PKG_DATADIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))

configure_file(
  output: 'config.h',
  configuration: conf
)

subdir('data')
subdir('po')

# Create a new executable
executable(
    meson.project_name(),
    'src/CatMenu.vala',
    'src/MenuServer.vala',
    'src/MenuClient.vala',
    'src/MenuApplication.vala',
    'src/MenuWindow.vala',
    'src/Data/MenuData.vala',
    'src/Data/ItemData.vala',
    'src/Data/CategoryData.vala',
    'src/Data/RowData.vala',
    'src/View/MenuCategory.vala',
    'src/View/MenuItem.vala',
    'src/View/PlaceItem.vala',

    import('gnome').compile_resources(
        'as-resources', join_paths('data', meson.project_name() + '.gresource.xml'),
        source_dir: 'data',
        c_name: 'as'
    ),
    c_args: [
      '-include', 'config.h',
      '-w', 
      '-O2',
      '-DGETTEXT_PACKAGE="' + meson.project_name() + '"'
    ],
    vala_args: [
        meson.source_root() + '/vapi/config.vapi'
    ],
    dependencies: [
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('glib-2.0'),
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('gdl-3.0'),
        dependency('libxml-2.0'),
        meson.get_compiler('c').find_library('m', required: false)        
    ],
    # link_args: ['-lm'],
    install: true
)

# Add post install script
meson.add_install_script('meson/post_install.py')
