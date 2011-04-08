/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function(config) {
  config.language = 'en';
  config.entities = false;
  config.toolbar_Basic = [
    ['Format'],
    ['NumberedList','BulletedList','Outdent','Indent'],
    ['Blockquote','CreateDiv'],
    ['Link','Unlink','Anchor'],
    ['PasteFromWord'],
    ['Table'],
    ['Maximize', 'ShowBlocks', 'Source']
  ];
  config.toolbar = 'Basic';
};