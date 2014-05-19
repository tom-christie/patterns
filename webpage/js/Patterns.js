
(function (scope) {

    window.this = window.this || {};

    function Patterns() {
        // throw exceptions on sloppy code
        // "use strict";

        this.debugmode = 1; // 1 for debug info and profiler, >1 for DETAILED INFO

        this.init();

    }

    Patterns.prototype = {
        constructor: Patterns,


        init: function () {

            // Create a canvas
            this.patternCanvas = document.createElement("canvas");
            // liquid layout: stretch to fill
            this.patternCanvas.width = Math.max(window.innerWidth, 1200); //so the canvas doesn't get too small, and so you can resize without it being retarded
            this.patternCanvas.height = Math.max(window.innerHeight, 700);
            // the id the game engine looks for
            this.patternCanvas.id = 'patternCanvas';
            // add the canvas element to the html document
            document.body.appendChild(this.patternCanvas);
            this.stage = new createjs.Stage(this.patternCanvas); //stage belongs to the canvas?
            this.stage.enableMouseOver();


            //background

            this.background = new createjs.Shape();
            this.background.graphics.clear().beginFill("#E3B706").drawRect(0, 0, this.patternCanvas.width, this.patternCanvas.height);
            this.stage.addChild(this.background);
            this.stage.update();

            //load manifest
            this.assets = new createjs.LoadQueue(true);
            this.assets.loadFile({id:"manifest",src:"assets/manifest.json"});
            this.assets.on("complete", this.launch.bind(this));

//            //set up keyboard listener
//            this.keyboardListener = new window.keypress.Listener();


        },

        launch: function () {

            var i;

            //make settings easier to get
            this.settings = {};
            for (asset in this.assets._loadedResults.manifest) {
                this.settings[asset] = this.assets._loadedResults.manifest[asset];
            }

            //add ticker
            createjs.Ticker.setFPS(30);
            createjs.Ticker.addEventListener('tick', this.onTick.bind(this));//callback function for what to do on each tick



            /********************
            TESTING
            ********************/
            this.stage.addChild(geo.stage);
            var p1 = geo.point(this.patternCanvas.width/2, this.patternCanvas.height/2);

            var c_outer = geo.circleFromPoint(p1,200);
            var c_outer_points = c_outer.getEquallySpacedPoints(10);
            var c_outer_points_lines = geo.connectEveryN(c_outer_points, 2);
//            for(i=0; i<c_outer_points_lines.length; i++){
//                var pts = geo.getAllIntersections(c_outer_points_lines[i]);
//            }

            var c_inner = geo.circleFromPoint(p1,100);
            var c_inner_points = c_inner.getEquallySpacedPoints(10);
            var c_inner_points_lines = geo.connectEveryN(c_inner_points, 2);
//            for(i=0; i<c_inner_points_lines.length; i++){
//                var pts = geo.getAllIntersections(c_inner_points_lines[i]);
//            }

            geo.draw(this.patternCanvas);
        },


        onTick: function () {
            this.stage.update();
        },


        initStates: function () {

        }

    };


    scope.Patterns = Patterns;

}(window));

