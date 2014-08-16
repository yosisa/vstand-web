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
          url: '/tree/:name/*path'
          views:
            'main':
              templateUrl: '/views/browse.tree.html'
              controller: 'BrowseCtrl'
          resolve:
            item: ['$stateParams', '$http', ($stateParams, $http) ->
              path = $stateParams.path || ''
              $http.get "/api/browse/#{$stateParams.name}/#{path}"
            ]

        .state 'browse.video',
          url: '/item/:name/*path'
          views:
            'main':
              templateUrl: '/views/video.html'
              controller: 'VideoCtrl'

        .state 'status',
          url: '/status'
          templateUrl: '/views/status.html'
          controller: 'RootCtrl'

        $urlRouterProvider.otherwise '/browse'
    ]

angular.module 'vstand'
  .controller 'MainCtrl', [
    '$scope'
    '$http'
    '$timeout'
    '$ionicModal'
    ($scope, $http, $timeout, $ionicModal) ->
      $ionicModal.fromTemplateUrl '/views/activity.html',
        scope: $scope
        animation: 'slide-in-up'
      .then (modal) ->
        $scope.modal = modal

      $scope.showActivity = ->
        $http.get '/api/tasks'
          .success (data) ->
            $scope.tasks = data
        $scope.modal.show()

      $scope.hideActivity = ->
        $scope.modal.hide()

      $scope.stop = (task) ->
        $http.delete "/api/tasks/#{task.id}"
          .success ->
            $timeout ->
              $http.get '/api/tasks'
                .success (data) ->
                  $scope.tasks = data
            , 100
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
    'item'
    ($scope, $stateParams, $http, item) ->
      $scope.name = $stateParams.name
      if $stateParams.path
        index = $stateParams.path.lastIndexOf "/"
        $scope.title = $stateParams.path[index+1..]
      else
        $scope.title = $stateParams.name

      $scope.cwd = if $stateParams.path then "#{$stateParams.path}/" else ""
      $scope.dirs = (x for x in item.data when x.dir)
      $scope.files = (x for x in item.data when !x.dir)
  ]

angular.module 'vstand'
  .controller 'VideoCtrl', [
    '$scope'
    '$stateParams'
    '$http'
    ($scope, $stateParams, $http) ->
      index = $stateParams.path.lastIndexOf "/"
      $scope.title = $stateParams.path[index+1..]
      $scope.videoSrc = "/video/stream?path=/#{$stateParams.name}/#{$stateParams.path}"
  ]
