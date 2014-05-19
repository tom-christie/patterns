/**
 * Created by Tom on 4/7/14.
 */

/*
 * Debug console output.
 */
function log(str) {
    console.log(str);
}

stupid = 1;
function distanceBetween(obj1, obj2){
    try{
    return Math.sqrt( Math.pow(obj1.x - obj2.x ,2) + Math.pow(obj1.y - obj2.y ,2) );
    } catch(err){
        if(stupid){console.log('uh oh',obj1,obj2); stupid=0;}
    }
}

/*
 * inheritance helper function
 * Use it like this --
 * function ChildFunc(){
 * ParentFunc.call(this,args);
 * };
 * inheritPrototype(ChildFunc,ParentFunc)
 *
 * //rest of definition goes here
 */

function inheritPrototype(childObject, parentObject) {
    // As discussed above, we use the Crockford’s method to copy the properties and methods from the parentObject onto the childObject
    // So the copyOfParent object now has everything the parentObject has
    var copyOfParent = Object.create(parentObject.prototype);

    //Then we set the constructor of this new object to point to the childObject.
    // Why do we manually set the copyOfParent constructor here, see the explanation immediately following this code block.
    copyOfParent.constructor = childObject;

    // Then we set the childObject prototype to copyOfParent, so that the childObject can in turn inherit everything from copyOfParent (from parentObject)
    childObject.prototype = copyOfParent;
}