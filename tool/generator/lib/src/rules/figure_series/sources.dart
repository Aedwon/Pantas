// Literal reserved source figures and wording from production content
// 88f38e698. Source 0017 re-synced to fixed production root 646326517.
const seriesSources = '''
{
  "ray-step": {
    "id": "q-spatial-abstract-reasoning-figure-series-0001",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "square",
          "line": 0
        },
        {
          "form": "square",
          "line": 45
        },
        {
          "form": "square",
          "line": 90
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Line pointing lower-right"
      },
      {
        "text": "Line pointing down"
      },
      {
        "text": "Line pointing up"
      },
      {
        "text": "Line pointing upper-right"
      }
    ]
  },
  "binary-fill": {
    "id": "q-spatial-abstract-reasoning-figure-series-0003",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "circle",
          "fill": "black"
        },
        {
          "form": "circle",
          "fill": "white"
        },
        {
          "form": "circle",
          "fill": "black"
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "White circle"
      },
      {
        "text": "Black circle"
      },
      {
        "text": "Half-filled circle"
      },
      {
        "text": "Quarter-filled circle"
      }
    ]
  },
  "size-fill": {
    "id": "q-spatial-abstract-reasoning-figure-series-0004",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "triangle",
          "size": "small",
          "fill": "black"
        },
        {
          "form": "triangle",
          "size": "medium",
          "fill": "white"
        },
        {
          "form": "triangle",
          "size": "large",
          "fill": "black"
        },
        {
          "form": "triangle",
          "size": "small",
          "fill": "white"
        },
        {
          "form": "triangle",
          "size": "medium",
          "fill": "black"
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Large white triangle"
      },
      {
        "text": "Large black triangle"
      },
      {
        "text": "Small white triangle"
      },
      {
        "text": "Medium white triangle"
      }
    ]
  },
  "two-arrow-turns": {
    "id": "q-spatial-abstract-reasoning-figure-series-0006",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "circle",
          "arrow": "up"
        },
        {
          "form": "circle",
          "arrow": "right"
        },
        {
          "form": "circle",
          "arrow": "down"
        }
      ],
      "blank": false
    },
    "choices": [
      {
        "text": "Arrow pointing up"
      },
      {
        "text": "Arrow pointing left"
      },
      {
        "text": "Arrow pointing right"
      },
      {
        "text": "Arrow pointing down"
      }
    ]
  },
  "dots-size": {
    "id": "q-spatial-abstract-reasoning-figure-series-0009",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "star",
          "dots": 1,
          "size": "small"
        },
        {
          "form": "star",
          "dots": 2,
          "size": "large"
        },
        {
          "form": "star",
          "dots": 3,
          "size": "small"
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Large star with four dots"
      },
      {
        "text": "Small star with four dots"
      },
      {
        "text": "Large star with three dots"
      },
      {
        "text": "Large star with two dots"
      }
    ]
  },
  "arrow-alternation": {
    "id": "q-spatial-abstract-reasoning-figure-series-0010",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "square",
          "arrow": "up"
        },
        {
          "form": "square",
          "arrow": "right"
        },
        {
          "form": "square",
          "arrow": "up"
        },
        {
          "form": "square",
          "arrow": "right"
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Arrow pointing up"
      },
      {
        "text": "Arrow pointing down"
      },
      {
        "text": "Arrow pointing right"
      },
      {
        "text": "Arrow pointing left"
      }
    ]
  },
  "two-fill-steps": {
    "id": "q-spatial-abstract-reasoning-figure-series-0011",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "square",
          "fill": 0.25
        },
        {
          "form": "square",
          "fill": 0.5
        },
        {
          "form": "square",
          "fill": 0.75
        },
        {
          "form": "square",
          "fill": 0.25
        },
        {
          "form": "square",
          "fill": 0.5
        }
      ],
      "blank": false
    },
    "choices": [
      {
        "text": "Quarter-filled square"
      },
      {
        "text": "Fully filled square"
      },
      {
        "text": "Half-filled square"
      },
      {
        "text": "Three-quarter-filled square"
      }
    ]
  },
  "outline-triple": {
    "id": "q-spatial-abstract-reasoning-figure-series-0012",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "circle"
        },
        {
          "form": "triangle"
        },
        {
          "form": "square"
        },
        {
          "form": "circle"
        },
        {
          "form": "triangle"
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Square"
      },
      {
        "text": "Circle"
      },
      {
        "text": "Triangle"
      },
      {
        "text": "Pentagon"
      }
    ]
  },
  "four-tracks": {
    "id": "q-spatial-abstract-reasoning-figure-series-0013",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "triangle",
          "size": "small",
          "edgeLines": 1,
          "line": 0
        },
        {
          "form": "square",
          "size": "medium",
          "edgeLines": 2,
          "line": 90
        },
        {
          "form": "triangle",
          "size": "small",
          "edgeLines": 3,
          "line": 180
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Medium square; line left; four edge lines"
      },
      {
        "text": "Medium square; line left; three edge lines"
      },
      {
        "text": "Small square; line left; four edge lines"
      },
      {
        "text": "Medium triangle; line down; four edge lines"
      }
    ]
  },
  "corner-edge-count": {
    "id": "q-spatial-abstract-reasoning-figure-series-0014",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "square",
          "dot": "top-left",
          "edgeLines": 1
        },
        {
          "form": "square",
          "dot": "top-right",
          "edgeLines": 2
        },
        {
          "form": "square",
          "dot": "bottom-right",
          "edgeLines": 3
        },
        {
          "form": "square",
          "dot": "bottom-left",
          "edgeLines": 4
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Top-left dot; five edge lines"
      },
      {
        "text": "Bottom-left dot; five edge lines"
      },
      {
        "text": "Top-left dot; four edge lines"
      },
      {
        "text": "Top-right dot; five edge lines"
      }
    ]
  },
  "double-fill": {
    "id": "q-spatial-abstract-reasoning-figure-series-0015",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "pentagon",
          "fill": "black"
        },
        {
          "form": "pentagon",
          "fill": "black"
        },
        {
          "form": "pentagon",
          "fill": "white"
        },
        {
          "form": "pentagon",
          "fill": "black"
        },
        {
          "form": "pentagon",
          "fill": "black"
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "White pentagon"
      },
      {
        "text": "Black pentagon"
      },
      {
        "text": "Half-filled pentagon"
      },
      {
        "text": "White circle"
      }
    ]
  },
  "transfer-count": {
    "id": "q-spatial-abstract-reasoning-figure-series-0016",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "square",
          "dots": 0,
          "edgeLines": 3
        },
        {
          "form": "square",
          "dots": 1,
          "edgeLines": 2
        },
        {
          "form": "square",
          "dots": 2,
          "edgeLines": 1
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Three dots; zero edge lines"
      },
      {
        "text": "Three dots; one edge line"
      },
      {
        "text": "Two dots; zero edge lines"
      },
      {
        "text": "Three dots; three edge lines"
      }
    ]
  },
  "interleaved-count": {
    "id": "q-spatial-abstract-reasoning-figure-series-0017",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "circle",
          "dots": 1
        },
        {
          "form": "square",
          "dots": 4
        },
        {
          "form": "circle",
          "dots": 2
        },
        {
          "form": "square",
          "dots": 4
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Circle with three dots"
      },
      {
        "text": "Square with four dots"
      },
      {
        "text": "Circle with five dots"
      },
      {
        "text": "Circle with two dots"
      }
    ]
  },
  "fill-ray-dots": {
    "id": "q-spatial-abstract-reasoning-figure-series-0018",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "square",
          "fill": 0.75,
          "line": 0,
          "dots": 1
        },
        {
          "form": "square",
          "fill": 0.5,
          "line": 90,
          "dots": 2
        },
        {
          "form": "square",
          "fill": 0.75,
          "line": 0,
          "dots": 3
        },
        {
          "form": "square",
          "fill": 0.5,
          "line": 90,
          "dots": 4
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Three-quarter-filled square; line up"
      },
      {
        "text": "Half-filled square; line up"
      },
      {
        "text": "Three-quarter-filled square; line right"
      },
      {
        "text": "Fully filled square; line up"
      }
    ]
  },
  "size-corner-ray": {
    "id": "q-spatial-abstract-reasoning-figure-series-0020",
    "figureSpec": {
      "kind": "figure-series",
      "items": [
        {
          "form": "square",
          "size": "medium",
          "dot": "top-left",
          "line": 90
        },
        {
          "form": "square",
          "size": "large",
          "dot": "top-right",
          "line": 0
        },
        {
          "form": "square",
          "size": "medium",
          "dot": "bottom-right",
          "line": 90
        },
        {
          "form": "square",
          "size": "large",
          "dot": "bottom-left",
          "line": 0
        }
      ],
      "blank": true
    },
    "choices": [
      {
        "text": "Medium square; dot top-left; line right"
      },
      {
        "text": "Large square; dot top-left; line right"
      },
      {
        "text": "Medium square; dot bottom-left; line right"
      },
      {
        "text": "Medium square; dot top-left; line up"
      }
    ]
  }
}
''';
