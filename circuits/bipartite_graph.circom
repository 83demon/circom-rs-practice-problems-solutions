pragma circom 2.0.0;

/* A bipartite graph is a graph that can be colored with two colors such that no two neighboring nodes share the same color. Devise an arithmetic circuit scheme to show you have a valid witness of a 2-coloring of a graph. Hint: the scheme in this tutorial needs to be adjusted before it will work with a 2-coloring.
The circuit below checks whether a witness is correct for a given graph.*/

template BipartiteGraph(N,E, edges) {
    signal input node_colors[N];
    
    // For example: [[0, 1], [1, 2], [2, 3]]

	for (var i=0; i<N; i++) {
		// We ensure colors are only 1 or 2
		0 === (node_colors[i] - 1) * (node_colors[i] - 2); 
	}

	for (var i=0; i<E; i++) {
		// We ensure adjacent nodes are of different colors. 1*1 = 1 and 2*2 = 4 are discarded.
		var node1 = edges[i][0];
		var node2 = edges[i][1];

		0 === (2 - node_colors[node1] * node_colors[node2]);
	}

}

component main = BipartiteGraph(8, 8, [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[2,7]]);
