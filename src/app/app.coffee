angular.module('vstand', [
  'ngRoute'
  'vstand-templates'
  'onsen.directives'
])

angular.module 'vstand'
  .controller 'RootCtrl', [
    '$scope'
    '$http'
    ($scope, $http) ->
      $scope.title = "Browse"
      $scope.pushPage = (name) ->
        $scope.ons.navigator.pushPage '/views/page1.html', name: name

      $http.get('/api/browse')
        .success (data) ->
          $scope.names = data
  ]

angular.module 'vstand'
  .controller 'BrowseCtrl', [
    '$scope'
    '$http'
    ($scope, $http) ->
      opts = $scope.ons.navigator.getCurrentPage().options
      if opts.path
        index = opts.path.lastIndexOf "/"
        $scope.title = opts.path[index+1..]
      else
        $scope.title = opts.name

      $scope.cwd = opts.path || ''
      $scope.pushPage = (item) ->
        next = if item.dir then '/views/page1.html' else '/views/video.html'
        $scope.ons.navigator.pushPage next,
          name: opts.name, path: "#{$scope.cwd}/#{item.name}"

      path = opts.path || '/'
      $http.get("/api/browse/#{opts.name}#{path}")
        .success (data) ->
          $scope.dirs = (x for x in data when x.dir)
          $scope.files = (x for x in data when !x.dir)
  ]

angular.module 'vstand'
  .controller 'VideoCtrl', [
    '$scope'
    '$http'
    ($scope, $http) ->
      opts = $scope.ons.navigator.getCurrentPage().options
      index = opts.path.lastIndexOf "/"
      $scope.title = opts.path[index+1..]
      $scope.videoSrc = "/video/stream?path=/#{opts.name}#{opts.path}"
  ]
