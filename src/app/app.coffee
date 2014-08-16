angular.module('vstand', [
  'ngRoute'
  'vstand-templates'
  'ionic'
])

  .config [
    '$stateProvider'
    '$urlRouterProvider'
    ($stateProvider, $urlRouterProvider) ->
      $stateProvider
        .state 'browse',
          url: '/browse'
          abstract: true
          templateUrl: '/views/browse.html'
          controller: 'MainCtrl'

        .state 'browse.root',
          url: ''
          views:
            'main':
              templateUrl: '/views/browse.root.html'
              controller: 'RootCtrl'

        .state 'browse.tree',
          url: '/:name/*path'
          views:
            'main':
              templateUrl: '/views/browse.tree.html'
              controller: 'BrowseCtrl'

        .state 'status',
          url: '/status'
          templateUrl: '/views/status.html'
          controller: 'RootCtrl'

        $urlRouterProvider.otherwise '/browse'
    ]

angular.module 'vstand'
  .controller 'MainCtrl', [
    '$scope'
    '$ionicModal'
    ($scope, $ionicModal) ->
      $ionicModal.fromTemplateUrl '/views/activity.html',
        scope: $scope
        animation: 'slide-in-up'
      .then (modal) ->
        $scope.modal = modal

      $scope.showActivity = ->
        $scope.activities = ['Item 1', 'Item 2']
        $scope.modal.show()

      $scope.hideActivity = ->
        $scope.modal.hide()

      $scope.stop = (index) ->
        $scope.activities.splice index, 1
  ]

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
    '$stateParams'
    '$http'
    ($scope, $stateParams, $http) ->
      console.log "BrowseCtrl"
      $scope.name = $stateParams.name
      if $stateParams.path
        index = $stateParams.path.lastIndexOf "/"
        $scope.title = $stateParams.path[index+1..]
      else
        $scope.title = $stateParams.name

      $scope.cwd = if $stateParams.path then "/#{$stateParams.path}/" else "/"
      path = "/#{$stateParams.path}"
      $http.get("/api/browse/#{$stateParams.name}#{path}")
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
