/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/
CKEDITOR.stylesSet.add('my_styles', [
    // Block-level styles
    { name : 'Lead', element : 'p', attributes : { 'class' : 'lead' } },
]);

CKEDITOR.editorConfig = function(config) {
  config.language = 'en';
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
  config.height = 500;
  config.stylesSet = 'my_styles';
  config.toolbar = 'Basic';
  config.forcePasteAsPlainText = true;
};