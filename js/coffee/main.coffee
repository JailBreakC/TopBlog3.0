requirejs.config
    paths:
        'angular': '../build/lib/angular-route-animate.min'
        'jquery': '../build/lib/jquery.min'
        'bootstrap': '../build/lib/bootstrap.min'
        'markdown': '../build/lib/markdown.min'
        'hljs': '../build/lib/highlight.pack'
        #'skel': '../build/lib/skel.min'
    shim: 
        'angular':
            exports: 'angular'
        'bootstrap':
            deps: ['jquery'],
            exports: 'bootstrap'
        'markdown':
            exports: 'markdown'

requirejs ['jquery', 'angular', 'bootstrap'], ($, angular) ->
    debug = false

    angular.element(document).ready ->
        # setTimeout解决在ng定义前就执行bootstrap的问题。
        setTimeout ->
            angular.bootstrap(document, ['myblog'])

    app = angular.module 'myblog', [
        'ui.router'
        'ngAnimate'
    ]
    app.config [
        '$stateProvider',
        '$urlRouterProvider',
        ($stateProvider, $urlRouterProvider) -> 
            $stateProvider.state('index', 
                url: '',
                templateUrl: '/template/page-main.html'
            ).state('main', 
                url: '/',
                templateUrl: '/template/page-main.html'
            ).state('cv',
                url: '/cv',
                templateUrl: '/template/page-cv.html'
            ).state('contact',
                url: '/contact',
                templateUrl: '/template/page-msg.html'
            ).state('project',
                url: '/projects',
                templateUrl: '/template/page-project.html'
            ).state('blog',
                url: '/blog',
                templateUrl: '/template/page-blog.html',
                controller: 'blog'
            ).state('blog.list',
                url: '/:type',
                templateUrl: '/template/page-blog-list.html',
                controller: 'bloglist'
            ).state('blog.detail',
                url: '/post/:article',
                templateUrl: '/template/page-blog-detail.html',
                controller: 'blogdetail'
            ).state('developing',
                url: '/developing'
                templateUrl: '/template/page-developing.html'
            )
            if debug
                $urlRouterProvider.otherwise('/');
            else 
                $urlRouterProvider.otherwise('/developing');


    ]


    app.factory 'AuthService', [
        '$http',
        ($http) ->
            fn = {};
            return {};
    ]


    #博客列表的动画，滚动时在下方出现
    app.directive 'celAnimate',['$rootScope', ($rootScope) ->
        restrict: 'EA'
        link: (scope,element,attrs) ->
            if $(window).width() < 768 then return
            $(element).addClass('cel-hide')
            scrollCheck = 0
            animationCheck = ->
                if $(element).hasClass('cel-show') then return

                height = $(window).height()
                top = $(window).scrollTop()
                pos = $(element).offset().top
                if pos - top <= height
                    $(element).removeClass('cel-hide').addClass('cel-show')
                scrollCheck = 1
            #初始化首次检测
            animationCheck()
            #滚动式检测动画
            $(window).scroll ->
                scrollCheck = 0
                
            #页面切换时，检测动画
            $rootScope.$on('$routeChangeSuccess', ->
                setTimeout ->
                    animationCheck()
            )
            #节流，每200毫秒执行一次滚动动画检测
            setInterval( ->
                if scrollCheck == 0
                    animationCheck()
            , 200)
        ]

    #模拟 css background-size: cover ， 让元素本身也能相对于窗口cover
    app.directive 'cover', -> 
        restrict: 'EA'
        link: (scope, element, attrs) ->
            cover = ->
                element = $(element);
                ew = element.width()
                ww = $(window).width()
                eh = element.height()
                wh = $(window).height()
                #按需放大
                element.css('min-width', wh*ew/eh + 'px');
                #居中
                if(wh == eh)
                    element.css('left', '-' + (ew-ww)/2 + 'px')
                else
                    element.css('left', 0)
            cover()
            window.onresize = ->
                cover()

    app.directive 'changeFont', ->
        restrict: 'A'
        link: (scope, element, attrs) ->
            fonts = [
                'cursive',
                '-webkit-body',
                '-webkit-pictograph',
                'fantasy',
                'serif'
            ]
            i = 0
            task = {}
            $(element).hover( ->
                that = @
                title = $('.navbar-brand');
                task.now = setInterval $.proxy( ->
                    $(title).css('font-family',fonts[i]);
                    $(that).css('font-family',fonts[i]);
                    if ++i >= 5
                        i = 0
                ), 200
            , ->
                clearInterval(task.now)
            )

    #滚动时主标题文字变大变虚
    app.directive 'scrollFade', ->
        restrict: 'A'
        link: (scope, element, attrs) ->
            if $(window).width() < 768 then return
            $ele = $(element)
            $window = $(window)
            eHeight = $ele.height()
            eTop = $ele.offset().top
            $window.scroll ->
                wTop = $window.scrollTop()
                if wTop > eTop && wTop - eTop <= eHeight * 2
                    size = (wTop - eTop) / (eHeight * 2) + 1
                    opacity = 1 - (wTop - eTop) / (eHeight * 2)
                    $ele.css({'transform': 'scale('+size+')', 'opacity': opacity})


    app.directive 'drag', ->
        restrict: 'EA'
        link: (scope, element, attrs) ->
            element = $(element);
            moveDrag = ->
                start = 0
                X = 0
                Y = 0
                element.mousedown (event) ->
                    console.log X
                    start = 1
                    #console.log 'start1'+start
                    X = event.clientX
                    Y = event.clientY
                    $('body').mousemove (eve) ->
                        console.log 'start2'+start
                        if start
                            theX = eve.clientX - X
                            X = eve.clientX
                            #console.log 'x'+X+'cx'+eve.clientX+'thx'+theX
                            element.parent().css('left', '+=' + theX + 'px')
                            $('.bk-left').css('width', '+=' + theX + 'px')
                            $('.bk-right').css('left', '+=' + theX + 'px')
                    $('body').mouseup () ->
                        #console.log 'up'
                        if start == 1
                            start = 0;
                            $('body').unbind 'mousemove'
                            $('body').unbind 'mouseup'
            moveDrag()

    app.directive 'showDetail', ->
        restrict: 'A'
        link: (scope, element, attrs) ->
            $target = $('.bk-'+ attrs.showDetail)
            $(element).hover( ->
                if $(window).width() > 768
                    $target.addClass('active');
                    $('.round').not($(this)).addClass('fadeout');
            ->
                if $(window).width() > 768
                    $target.removeClass('active');
                    $('.round').not($(this)).removeClass('fadeout');
            )
    app.directive 'vgGo', ->
        restrict: 'A'
        link: (scope, element, attrs) ->
            $(element).click ->
                window.location.href = attrs.vgGo;

    app.directive 'markdown', ->
        restrict: 'A'
        scope: {
            content: '=markdownText'
        },
        link: (scope, element, attrs)-> 
            them = if attrs.theme then attrs.theme else 'zenburn'
            cssUrl = require.toUrl('/style/lib/hightlight/' + them + '.css')
            link = document.createElement('link')
            link.type = 'text/css'
            link.rel = 'stylesheet'
            link.href = cssUrl
            document.getElementsByTagName('head')[0].appendChild(link);
            loading = '<div class="spinner">
                          <div class="rect1"></div>
                          <div class="rect2"></div>
                          <div class="rect3"></div>
                          <div class="rect4"></div>
                          <div class="rect5"></div>
                      </div>'
            
            element.html loading
            #动态加载markdown 和 highlight 
            requirejs ['markdown', 'hljs'], (md, hljs) ->
                scope.$watch( ->
                    return scope.content
                , (newValue)->
                    if newValue
                        element.html md.toHTML(newValue)
                        $(element).find('pre>code').each (i, block) ->
                           return hljs.highlightBlock block
                    else
                        element.html loading

                )
                if scope.content
                    element.html md.toHTML(scope.content)
                    $(element).find('pre>code').each (i, block) ->
                       return hljs.highlightBlock block
                else
                    element.html loading

    app.directive 'themeSwitcher', ->
        restrict: 'E'
        scope: {
            themes: '=themes'
        }
        controller: ['$scope', '$rootScope', '$timeout', '$http', ($scope, $rootScope, $timeout, $http)->
            themes = []
            imgs = 
                'green': 'http://gtms01.alicdn.com/tps/i1/TB1I3coIFXXXXaOXpXXxjZKVXXX-1200-675.jpg_1080x1800.jpg'
                'pink': 'http://gtms03.alicdn.com/tps/i3/TB1CUj9IFXXXXbNaXXX9l.7UFXX-1920-1080.jpg_1080x1800.jpg'
                'purple': 'http://gtms04.alicdn.com/tps/i4/TB1euAmIFXXXXbnXpXX9l.7UFXX-1920-1080.jpg_1080x1800.jpg'
                'blue': 'http://gtms01.alicdn.com/tps/i1/TB1jEEuIFXXXXXrXXXX9l.7UFXX-1920-1080.jpg_1080x1800.jpg'
                'yellow': 'http://gtms03.alicdn.com/tps/i3/TB1e4EaIFXXXXcuXVXX9l.7UFXX-1920-1080.jpg_1080x1800.jpg'

            this.gotChanged = (theme)->
                #预加载图片
                bk = []
                bk.img = new Image()
                #判断浏览器支持 如果支持xhr2 则使用加载blob的方法加载图片
                if window.URL.createObjectURL
                    $rootScope.$broadcast('themeChangeStart', {'fake': false})
                    xhr = new XMLHttpRequest()
                    xhr.open('GET', imgs[theme.color])
                    xhr.responseType = 'blob'
                    xhr.onreadystatechange = ->
                        if xhr.readyState is 4
                            bk.url = window.URL.createObjectURL(xhr.response)
                    xhr.onprogress = (e) ->
                        $rootScope.$apply ->
                            $rootScope.$broadcast('themeChangeProgress', e)
                    xhr.send()
                else  
                    $rootScope.$broadcast('themeChangeStart', {'fake': true})
                    bk.img.src = bk.url = imgs[theme.color]

                xhr.onload = bk.img.onload = ->
                    #需要将逻辑包进$rootScope.$apply 否则angular无法进行双向绑定！！！
                    $rootScope.$apply ->
                        themes.forEach (v) ->
                            if v != theme
                                v.selected = false;
                        #切换全局主题名        
                        $scope.themes.themeClass = 'theme-' + theme.color
                        background = 'url(' + bk.url + ')'
                        enterEle = $('.header-background.bg-leave')
                        leaveEle = $('.header-background.bg-enter')
                        leaveEle.removeClass('bg-enter').addClass('bg-leave')
                        enterEle.removeClass('bg-leave').addClass('bg-enter').css('background-image', background)
                        $rootScope.$broadcast('themeChangeSuccess')

            #首次打开页面也认为是切换主题
            $timeout( ->
                $rootScope.$broadcast('themeChangeSuccess')
            , 300)
            this.addThemes = (e) ->
                themes.push(e)
            return
        ]    

    app.directive 'switcher', ['$rootScope', '$timeout', ($rootScope, $timeout) ->
        restrict: 'EA'
        template: '<i ng-click="toggleTheme()" class="{{theme.selected ? \'active\' : \'\'}} glyphicon glyphicon-sunglasses"></i>'
        replace: true,
        transclude: true,
        require: '^themeSwitcher'
        scope: {
            theme: '=tm'
        }
        link: (scope,element,attr,themeSwitcherController) ->
            scope.theme.selected = false
            #首次打开页面也认为是切换主题
            $rootScope.$broadcast('themeChangeStart', {'fake': true})
            if scope.theme.color is 'green' then scope.theme.selected = true
            themeSwitcherController.addThemes(scope.theme);
            scope.toggleTheme = ->
                scope.theme.selected = true;
                themeSwitcherController.gotChanged(scope.theme)

    ]

    app.directive 'progressTool', ['$rootScope', '$timeout', ($rootScope, $timeout) ->
        restrict: 'EA'
        replace: true
        template: '<div class="progress {{mhide}}">
                      <div class="progress-bar progress-bar-danger" role="progressbar" aria-valuenow="{{percent}}" aria-valuemin="0" aria-valuemax="100" style="width: {{percent}}%;">
                        <span class="{{showPercent ? \'\' : \'sr-only\'}}">{{percent}}%</span>
                      </div>
                    </div>'
        scope: {
            percent: '=percent'
            showPercent: '=showPercent'
        }
        link: (scope, element, attrs) ->
            scope.mhide = ''
            scope.percent += ''
            scope.$watch( ->
                scope.percent
            , ->
                if scope.percent is '100'
                    #必须要用$timeout而不是setTimeout，否则双向绑定会失效
                    $timeout( ->
                        scope.percent = '0'
                        scope.mhide = 'hide'               
                    , 500)
                    $timeout( ->
                        scope.mhide = ''
                    , 800)
            )
    ]

    parseTitle = (data) ->
        r =
            title:''
            type:''
            tag:''
            disc:''
            url:''
            hide:''
        month = '零 一 二 三 四 五 六 七 八 九 十 十一 十二'.split(' ')
        for line in data.split('\n')
            [key,value] = line.split(':')
            key = $.trim key
            value = $.trim value
            (a, b, c)->
            if r.hasOwnProperty(key) then r[key]=value
        r.date = r.url.split('-')
        r.date.month = month[parseInt r.date[1],10]
        r.date.day =  parseInt r.date[2],10
        return r

    parseList = (data) ->
        r = []
        data = data.split(/\n[\-=]+/)
        data.forEach (list)->
            list = parseTitle(list)
            #剔除hide的的文章
            if list.hide isnt 'true' then r.push list
        return r

    parseType = (data) ->
        r = []
        data.forEach (list)->
            if r.indexOf(list.type) is -1
                r.push list.type
        return r


    parsePost = (text) ->
        flag = false
        head = ''
        tail = '' 
        for line in text.split('\n')
            if /[\-=]+/.test(line)
                flag=true
            if flag
                tail+= '\n'+line
            else
                head+= '\n'+line+'\n'
        post = parseTitle head
        post.text = tail
        if post.hide == 'true' then return
        return post

    filterType = (data,param) ->
        if param then type = param
        if type and data and type isnt 'all'
            output = []
            for i in data
                if i.type is type
                    output.push i
            ##console.log output
            return output
        return data

    app.filter 'blogListType', ->
        blogListType = filterType

    app.controller 'blog', [
        '$scope'
        '$http'
        '$rootScope'
        '$timeout'
        '$location'
        '$stateParams'
        ($scope,$http,$rootScope, $timeout, $location, $stateParams) ->
            ##$scope.routeType = $routeParams.type || 'all'
            $http.get('/post/list.md').success (data) ->
                #解析博客列表，
                $scope.blogList = $scope.blogListOrigin= parseList(data)
                #解析博客分类
                $scope.listType = parseType($scope.blogList)

            #主题加载
            $scope.percent = '0'
            $rootScope.$on('themeChangeStart', (e, data)->
                if(data.fake)
                    $scope.percent = '30'
                else
                    $scope.percent = '0'
            )
            $rootScope.$on('themeChangeSuccess', ->
                $scope.percent = '100'
            )
            $rootScope.$on('themeChangeProgress', (e, data)->
                $scope.percent = (data.loaded/data.total) * 100 + ''
                console.log($scope.percent)
            )

            $scope.themes = [
                {
                    color: 'green'
                    selected: true
                },
                {
                    color: 'blue'
                    selected: false
                },
                {
                    color: 'purple'
                    selected: false
                },
                {
                    color: 'yellow'
                    selected: false
                },
                {
                    color: 'pink'
                    selected: false
                }
            ]

            $scope.themes.themeClass = 'theme-green' 
            
        ]

    app.controller 'bloglist', [
        '$rootScope'
        '$scope'
        '$http'
        '$stateParams'
        ($rootScope, $scope, $http, $stateParams) ->
            $scope.blogtype = $rootScope.blogtype = $stateParams.type

    ]   
    app.controller 'blogdetail', [
        '$scope'
        '$http'
        '$stateParams'
        '$timeout'
        '$location'
        ($scope, $http, $stateParams, $timeout, $location) ->
            $http.get('/post/' + $stateParams.article).success (data) ->
                data = parsePost(data)
                $scope.title = data.title
                $scope.article = data.text
                #添加多说评论框
                toggleDuoshuoComments('.blog-detail')
            toggleDuoshuoComments = (container) ->
                el = document.createElement('div') #该div不需要设置class="ds-thread"
                el.setAttribute('id', $location.url()) #必选参数
                el.setAttribute('data-thread-key', $scope.title) #必选参数
                el.setAttribute('data-url', $location.url()) #必选参数
                #el.setAttribute('data-author-key', '作者的本地用户ID');//可选参数
                #console.log(el)
                DUOSHUO.EmbedThread(el)
                #console.log(el)
                jQuery(container).append(el)
    ]


