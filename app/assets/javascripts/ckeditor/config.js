CKEDITOR.stylesSet.add('porthos', [
  // Block-level styles
  { name : 'Ingress', element : 'p', attributes : { 'class' : 'lead' } }
]);

CKEDITOR.editorConfig = function(config) {
  config.language = 'sv';
  config.entities = false;
  config.toolbar_Basic = [
    ['Format','Styles'],
    ['Bold','Italic','Strike'],
    ['NumberedList','BulletedList'],
    ['Blockquote'],
    ['Link','Unlink','Anchor'],
    ['PasteFromWord'],
    ['Table'],
    ['Maximize', 'ShowBlocks', 'Source']
  ];

  config.extraPlugins = 'autogrow';
  config.autoGrow_minHeight = 400;
  config.autoGrow_maxHeight = 900;
  config.autoGrow_onStartup = true;
  config.removePlugins = 'resize';

  config.stylesSet = 'porthos';
  config.toolbar = 'Basic';

  config.forcePasteAsPlainText = true;
};
