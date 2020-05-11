# Droplet config editor
window.expressionContext = {
  prefix: 'a = '
}

window.dropletConfig = ace.edit 'droplet-config'
dropletConfig.setTheme 'ace/theme/chrome'
dropletConfig.getSession().setMode 'ace/mode/python'

# dropletConfig.setValue localStorage.getItem('config') ? '''
dropletConfig.setValue '''
  ({
    "mode": "python",
    "modeOptions": {
      "functions": {
        "myFunction": {
          "color": "purple",
          "dropdown": [['foo', 'bar'], ['baz', 'qux']]
        },
        'colorTest': {
          'color': 'yellow',
          'dropdown': [null, ['1', '2', '3']]
        },
        'nestedFn': {
          'color': 'pink'
        }
      }
    },
    "palette": [

      {
        'name': 'Operators',
        'color': 'yellow',
        'blocks': [

          { 'block': 'True' },
          { 'block': 'False' }
        ]
      },
      {
        'name': 'Controls',
        'color': 'green',
        'blocks': [
          { 'block': "if a == b:\\n  print ('This is a conditional statement!')" },
          { 'block': "while a == b:\\n  print ('This is a conditional loop!')" },
          { 'block': 'for i in list_variable:\\n  print (i)' },
          { 'block': 'break' },
          { 'block': 'continue' },
          { 'block': 'pass' }
        ]
      },
       {
        'name': 'Functions',
        'color': 'blue',
        'blocks': [
          { 'block': 'def FunctionName(args):\\n  return' },
          { 'block': 'FunctionName(args)' },
          { 'block': 'lambda_variable = lambda args: args * 2' },
          { 'block': 'return return_value' },
          { 'block': 'return' }
        ]
      },
      {
        'name': 'Classes',
        'color': 'purple',
        'blocks': [
          { 'block': "class ClassName:\\n def __init__(self, args):\\n  self.args = args\\n  print('NOTE: The self parameter is the instance that the method is called on!')\\n def __del__(self):\\n  class_name = self.__class__.__name__\\n  print(class_name + ' was destroyed!')" },
          { 'block': "class_object = ClassName('This is the default constructors args parameter!')" },
          { 'block': 'class_object.__init__()' }
        ]
      },
      {
        'name': 'Misc',
        'color': 'black',
        'blocks': [
          { 'block': '# this is a comment' },

        ]
      }
    ]
  })
'''

# Droplet itself
createEditor = (options) ->
  $('#droplet-editor').html ''
  editor = new droplet.Editor $('#droplet-editor')[0], options

  editor.setEditorState localStorage.getItem('blocks') is 'yes'
  editor.aceEditor.getSession().setUseWrapMode true

  # Initialize to starting text
  #editor.setValue localStorage.getItem('text') ? ''

  editor.on 'change', ->
    localStorage.setItem 'text', editor.getValue()

  window.editor = editor

createEditor eval dropletConfig.getValue()

$('#toggle').on 'click', ->
  editor.toggleBlocks()
  localStorage.setItem 'blocks', (if editor.currentlyUsingBlocks then 'yes' else 'no')

# Stuff for testing convenience
$('#update').on 'click', ->
  localStorage.setItem 'config', dropletConfig.getValue()
  createEditor eval dropletConfig.getValue()

configCurrentlyOut = localStorage.getItem('configOut') is 'yes'

updateConfigDrawerState = ->
  if configCurrentlyOut
    $('#left-panel').css 'left', '0px'
    $('#right-panel').css 'left', '525px'
  else
    $('#left-panel').css 'left', '-500px'
    $('#right-panel').css 'left', '25px'

  editor.resize()

  localStorage.setItem 'configOut', (if configCurrentlyOut then 'yes' else 'no')

$('#close').on 'click', ->
  configCurrentlyOut = not configCurrentlyOut
  updateConfigDrawerState()

updateConfigDrawerState()