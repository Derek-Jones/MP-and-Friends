var width = 960,
    height = 500;

var color = d3.scale.category20();

var force = d3.layout.force()
    .charge(-120)
    .linkDistance(30)
    .size([width, height]);

var svg = d3.select("#chartCanvas").append("svg")
    .attr("width", width)
    .attr("height", height);


function d3LoadData(jsonFile, errorFunc, successFunc){
    d3.json(jsonFile, function(error, graph) {

        if (error) {
            console.warn(error);
            errorFunc(error);
            return;
        }

        force
            .nodes(graph.nodes)
            .links(graph.links)
            .start();

        var link = svg.selectAll(".link")
            .data(graph.links)
            .enter().append("line")
            .attr("class", "link")
            .style("stroke-width", function(d) { return Math.sqrt(d.value); });

        var node = svg.selectAll(".node")
            .data(graph.nodes)
            .enter().append("circle")
            .attr("class", "node")
            .attr("r", 8)
            .style("fill", function(d) { return color(d.group); })
            .call(force.drag)
            .on("click", function(d){
                popup(d);
            });

        node.append("title")
            .text(function(d) { return d.name; });

        force.on("tick", function() {
            link.attr("x1", function(d) { return d.source.x; })
                .attr("y1", function(d) { return d.source.y; })
                .attr("x2", function(d) { return d.target.x; })
                .attr("y2", function(d) { return d.target.y; });

            node.attr("cx", function(d) { return d.x; })
                .attr("cy", function(d) { return d.y; });
        });


        successFunc();

        function popup(d){
            console.log(d);

        }
    });
}