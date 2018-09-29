#!/bin/bash

source utils.sh friendlyIO strings 

h0 "Running visual tests"

h1 "Strings"
h2 "ansifold"

echo
info "Confirm all lines do not extend beyond the end of the gauges"
echo
echo --------10--------20--------30--------40--------50--------60--------70--------80
echo $'\x1b[31;1mThe quick brown fox jumps over the lazy dog\x1b[0m The quick brown fox jumps\x1b[31;1m: over the lazy\x1b[0m [ \x1b[31mdog\x1b[0m ]' | ansifold
# echo --------10--------20--------30--------40--------50--------60--------70--------80
# echo $'\x1b[31;1mLorem \x1b[32;1mipsum \x1b[33;1mdolor \x1b[34;1msit \x1b[35;1mamet, \x1b[36;1mconsectetur \x1b[37;1madipiscing elit. Vestibulum venenatis lobortis purus nec rhoncus. Morbi odio leo, consectetur at orci nec, \x1b[0mtristique gravida quam. Phasellus posuere nunc sapien, ut consequat mauris eleifend ac. Mauris id leo bibendum, accumsan massa rutrum, cursus neque. Proin ligula mauris, tristique et enim eu, scelerisque bibendum nibh. Donec elementum, tortor in elementum placerat, orci mauris tincidunt augue, in blandit lectus neque ut magna. Integer commodo nunc nisl, at ullamcorper nunc pellentesque id. Interdum et malesuada fames ac ante ipsum primis in faucibus. Quisque pulvinar accumsan nisl eget pharetra. Vestibulum nunc diam, lobortis eget turpis congue, suscipit tincidunt urna. Donec imperdiet, diam pretium volutpat vulputate, dui nisi molestie tellus, quis sollicitudin ipsum justo vel ex. Vestibulum iaculis urna sem, eget tempus augue tincidunt eget. In maximus consectetur arcu, rhoncus consequat tellus accumsan vitae. Phasellus mollis tincidunt turpis ut tempor. Cras bibendum, mi a efficitur sollicitudin, lacus lacus bibendum nisi, in egestas magna purus eget tellus. Sed vel mauris quis nibh dictum dapibus.' | ansifold
echo --------10--------20--------30--------40--------50--------60--------70--------80
echo $'Aenean scelerisque pretium pretium. Nulla at eros non massa porta luctus ut in sapien. Praesent varius tortor vel orci congue, nec venenatis justo consectetur. Vivamus tincidunt accumsan nulla at pulvinar. Vivamus fringilla nisl justo, et iaculis magna viverra et. Praesent at tellus volutpat, fermentum velit in, pulvinar est. Vivamus posuere lorem nisi, bibendum lobortis justo pulvinar non. Integer malesuada aliquam tellus, eu ultricies libero. Quisque tempor feugiat elit ac tristique. Fusce aliquam posuere interdum. Nam orci sem, maximus eget orci ac, tempor ultricies tellus. Nulla facilisi. Nulla id magna at quam interdum viverra.' | ansifold
echo --------10--------20--------30--------40--------50--------60--------70--------80
echo
info $'This test should show the green text wrapping from the end of the first'
info $'line to the beginning of the second'
echo
echo --------10--------20--------30--------40--------50--------60--------70--------80
echo $'\x1b[31;1mPellentesque \x1b[32;1min turpis sit amet lorem euismod mattis non ut turpis. Aenean quis placerat arcu, \x1b[33;1mnon porta lorem\x1b[34;1m. In et porttitor magna. Etiam \x1b[0mut consequat mauris. Phasellus viverra posuere placerat. Nulla ornare nunc quis tempus congue. Vestibulum sodales viverra vulputate.' | ansifold
echo --------10--------20--------30--------40--------50--------60--------70--------80
# echo $'Nunc elit nisl, sodales quis commodo vitae, consectetur at mi. Morbi ac sapien dui. Donec lacus dolor, eleifend vitae consequat in, pretium ut odio. Integer nibh neque, fringilla in neque ut, consectetur euismod magna. Quisque hendrerit diam sed pharetra consectetur. Ut pulvinar libero vulputate, finibus velit et, rutrum risus. Phasellus vitae semper nibh. Curabitur bibendum velit non viverra pulvinar. Vestibulum lacinia pellentesque odio vel volutpat. Aenean sodales lorem velit, sed pharetra quam sagittis id. Vivamus dictum diam vitae massa mollis ornare vel eget nunc. Vestibulum ultricies ut nisi at tincidunt. Nunc vel eleifend elit. Ut ac risus sed sapien consequat ultricies. Mauris tincidunt quam sit amet massa scelerisque, id egestas lacus porta.' | ansifold
# echo --------10--------20--------30--------40--------50--------60--------70--------80
# echo $'Mauris a enim risus. Vestibulum ullamcorper ante et ante lobortis, eu efficitur erat luctus. Pellentesque bibendum enim a augue laoreet, ac ornare neque sagittis. Praesent bibendum eros placerat est viverra feugiat. Praesent ac scelerisque nulla. Donec bibendum lacinia vehicula. Pellentesque varius augue aliquam nisl scelerisque vulputate. Vestibulum eu enim ac nibh hendrerit lobortis at at est. In sit amet erat maximus, sodales erat non, varius elit. Sed pellentesque eros sed tempor rhoncus. In hac habitasse platea dictumst. Nunc faucibus rutrum nisl hendrerit hendrerit. Donec lacinia, diam sed facilisis aliquet, risus nunc mollis purus, nec maximus ex dolor a purus. Cras eu blandit dolor. Donec euismod, turpis a consequat finibus, risus ligula iaculis tellus, at rutrum augue lorem et elit. Interdum et malesuada fames ac ante ipsum primis in faucibus.' | ansifold
# echo --------10--------20--------30--------40--------50--------60--------70--------80


