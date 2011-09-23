Porthos::Routing::Recognize.rules.draw do
  match ":id",
    to: {
      controller: 'pages',
      action: 'show' },
    constraints: {
      id: '([a-z0-9\-\_]+)' }

  match ":year/:month/:day/:id",
    to: {
      controller: 'pages',
      action: 'show' },
    constraints: {
      :year => '(\d{4})',
      :month => '(\d{2})',
      :day => '(\d{2})',
      :id => '([a-z0-9\-\_]+)' }

  match ":year/:month/:day",
    to: {
      controller: 'pages',
      action: 'index' },
    constraints: {
      year:  '(\d{4})',
      month: '(\d{2})',
      day:   '(\d{2})' }

  match ":year/:month",
    to: {
      controller: 'pages',
      action: 'index' },
    constraints: {
      year:  '(\d{4})',
      month: '(\d{2})' }

  match ":year",
    to: {
      controller: 'pages',
      action: 'index' },
    constraints: {
      year: '(\d{4})' }

  match '%{categories}',
    to: {
      controller: 'pages',
      action: 'categories' }

  match "%{categories}/:id",
    to: {
      controller: 'pages',
      action: 'category' },
    constraints: {
      :id => '([a-z0-9\-\_\s\p{Word}]+)' }
end