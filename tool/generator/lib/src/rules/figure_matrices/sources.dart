// Literal production source figures and wording, revision 88f38e698.
const matrixSources = '''
{
  "ray-turn": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0001",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 2,
      "cols": 2,
      "cells": [
        {
          "form": "triangle",
          "line": 0
        },
        {
          "form": "triangle",
          "line": 90
        },
        {
          "form": "square",
          "line": 180
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Square with line pointing left",
        "correct": true
      },
      {
        "text": "Square with line pointing down"
      },
      {
        "text": "Square with line pointing right"
      },
      {
        "text": "Triangle with line pointing left"
      }
    ]
  },
  "size-columns": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0003",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 2,
      "cells": [
        {
          "form": "square",
          "size": "small"
        },
        {
          "form": "square",
          "size": "small"
        },
        {
          "form": "square",
          "size": "medium"
        },
        {
          "form": "square",
          "size": "medium"
        },
        {
          "form": "square",
          "size": "large"
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Large square",
        "correct": true
      },
      {
        "text": "Medium square"
      },
      {
        "text": "Small square"
      },
      {
        "text": "Large triangle"
      }
    ]
  },
  "size-fill": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0004",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "square",
          "size": "small",
          "fill": "black"
        },
        {
          "form": "square",
          "size": "small",
          "fill": "white"
        },
        {
          "form": "square",
          "size": "small",
          "fill": "black"
        },
        {
          "form": "square",
          "size": "medium",
          "fill": "black"
        },
        {
          "form": "square",
          "size": "medium",
          "fill": "white"
        },
        {
          "form": "square",
          "size": "medium",
          "fill": "black"
        },
        {
          "form": "square",
          "size": "large",
          "fill": "black"
        },
        "blank",
        {
          "form": "square",
          "size": "large",
          "fill": "black"
        }
      ]
    },
    "choices": [
      {
        "text": "Large white square",
        "correct": true
      },
      {
        "text": "Large black square"
      },
      {
        "text": "Medium white square"
      },
      {
        "text": "Small white square"
      }
    ]
  },
  "ray-union": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0005",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 2,
      "cols": 3,
      "cells": [
        {
          "form": "circle",
          "line": 90
        },
        {
          "form": "circle",
          "line": 0
        },
        {
          "form": "circle",
          "lines": [
            90,
            0
          ]
        },
        {
          "form": "square",
          "line": 45
        },
        {
          "form": "square",
          "line": 135
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Square with both diagonal rays",
        "correct": true
      },
      {
        "text": "Square with only the upper-right ray"
      },
      {
        "text": "Square with only the lower-right ray"
      },
      {
        "text": "Square with rays up and right"
      }
    ]
  },
  "fill-union": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0006",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 2,
      "cols": 3,
      "cells": [
        {
          "form": "square",
          "size": "small",
          "fill": 0.5
        },
        {
          "form": "square",
          "size": "small",
          "fill": 0.5,
          "rotation": 180
        },
        {
          "form": "square",
          "size": "small",
          "fill": "black"
        },
        {
          "form": "square",
          "size": "large",
          "fill": 0.5
        },
        {
          "form": "square",
          "size": "large",
          "fill": 0.5,
          "rotation": 180
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Fully black square",
        "correct": true
      },
      {
        "text": "Fully white square"
      },
      {
        "text": "Bottom-half-filled square"
      },
      {
        "text": "Top-half-filled square"
      }
    ]
  },
  "corner-step": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0007",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 2,
      "cols": 2,
      "cells": [
        {
          "form": "circle",
          "dot": "top-left"
        },
        {
          "form": "circle",
          "dot": "top-right"
        },
        {
          "form": "square",
          "dot": "top-left"
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Square with dot at top-right",
        "correct": true
      },
      {
        "text": "Square with dot at top-left"
      },
      {
        "text": "Square with dot at bottom-right"
      },
      {
        "text": "Square with dot at bottom-left"
      }
    ]
  },
  "size-dots": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0008",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "triangle",
          "size": "small",
          "dots": 1
        },
        {
          "form": "triangle",
          "size": "small",
          "dots": 2
        },
        {
          "form": "triangle",
          "size": "small",
          "dots": 3
        },
        {
          "form": "triangle",
          "size": "medium",
          "dots": 1
        },
        {
          "form": "triangle",
          "size": "medium",
          "dots": 2
        },
        {
          "form": "triangle",
          "size": "medium",
          "dots": 3
        },
        {
          "form": "triangle",
          "size": "large",
          "dots": 1
        },
        {
          "form": "triangle",
          "size": "large",
          "dots": 2
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Large triangle with three dots",
        "correct": true
      },
      {
        "text": "Large triangle with two dots"
      },
      {
        "text": "Medium triangle with three dots"
      },
      {
        "text": "Small triangle with three dots"
      }
    ]
  },
  "ray-intersection": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0009",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 2,
      "cols": 3,
      "cells": [
        {
          "form": "circle",
          "lines": [
            0,
            90
          ]
        },
        {
          "form": "circle",
          "lines": [
            0,
            180
          ]
        },
        {
          "form": "circle",
          "line": 0
        },
        {
          "form": "square",
          "lines": [
            45,
            135
          ]
        },
        {
          "form": "square",
          "lines": [
            135,
            225
          ]
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Square with only the lower-right ray",
        "correct": true
      },
      {
        "text": "Square with all three diagonal rays"
      },
      {
        "text": "Square with only the upper-right ray"
      },
      {
        "text": "Square with only the lower-left ray"
      }
    ]
  },
  "corner-reflection": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0010",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 2,
      "cols": 2,
      "cells": [
        {
          "form": "square",
          "dot": "top-left"
        },
        {
          "form": "square",
          "dot": "top-right"
        },
        {
          "form": "pentagon",
          "dot": "bottom-right"
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Pentagon with dot at bottom-left",
        "correct": true
      },
      {
        "text": "Pentagon with dot at top-right"
      },
      {
        "text": "Pentagon with dot at bottom-right"
      },
      {
        "text": "Square with dot at bottom-left"
      }
    ]
  },
  "binary-fill-row": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0011",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 2,
      "cols": 3,
      "cells": [
        {
          "form": "star",
          "fill": "black"
        },
        {
          "form": "star",
          "fill": "white"
        },
        {
          "form": "star",
          "fill": "black"
        },
        {
          "form": "star",
          "fill": "black"
        },
        {
          "form": "star",
          "fill": "white"
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Black star",
        "correct": true
      },
      {
        "text": "White star"
      },
      {
        "text": "Half-filled star"
      },
      {
        "text": "Black circle"
      }
    ]
  },
  "arrow-column": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0012",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 2,
      "cells": [
        {
          "form": "circle",
          "arrow": "up"
        },
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
          "arrow": "right"
        },
        "blank",
        {
          "form": "circle",
          "arrow": "down"
        }
      ]
    },
    "choices": [
      {
        "text": "Arrow pointing down",
        "correct": true
      },
      {
        "text": "Arrow pointing up"
      },
      {
        "text": "Arrow pointing left"
      },
      {
        "text": "Arrow pointing right"
      }
    ]
  },
  "form-ray": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0013",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "triangle",
          "line": 0
        },
        {
          "form": "triangle",
          "line": 45
        },
        {
          "form": "triangle",
          "line": 90
        },
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
        },
        {
          "form": "pentagon",
          "line": 0
        },
        {
          "form": "pentagon",
          "line": 45
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Pentagon with line pointing right",
        "correct": true
      },
      {
        "text": "Square with line pointing right"
      },
      {
        "text": "Pentagon with line pointing upper-right"
      },
      {
        "text": "Triangle with line pointing right"
      }
    ]
  },
  "sized-ray-union": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0014",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "square",
          "size": "small",
          "line": 90
        },
        {
          "form": "square",
          "size": "small",
          "line": 0
        },
        {
          "form": "square",
          "size": "small",
          "lines": [
            90,
            0
          ]
        },
        {
          "form": "square",
          "size": "medium",
          "line": 90
        },
        {
          "form": "square",
          "size": "medium",
          "line": 0
        },
        {
          "form": "square",
          "size": "medium",
          "lines": [
            90,
            0
          ]
        },
        {
          "form": "square",
          "size": "large",
          "line": 90
        },
        {
          "form": "square",
          "size": "large",
          "line": 0
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Large square with rays up and right",
        "correct": true
      },
      {
        "text": "Medium square with rays up and right"
      },
      {
        "text": "Large square with only the up ray"
      },
      {
        "text": "Large square with only the right ray"
      }
    ]
  },
  "outline-latin": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0015",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
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
          "form": "triangle"
        },
        {
          "form": "square"
        },
        {
          "form": "circle"
        },
        {
          "form": "square"
        },
        {
          "form": "circle"
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Triangle",
        "correct": true
      },
      {
        "text": "Circle"
      },
      {
        "text": "Square"
      },
      {
        "text": "Pentagon"
      }
    ]
  },
  "dot-sum": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0016",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "circle",
          "dots": 1
        },
        {
          "form": "circle",
          "dots": 2
        },
        {
          "form": "circle",
          "dots": 3
        },
        {
          "form": "circle",
          "dots": 2
        },
        {
          "form": "circle",
          "dots": 2
        },
        {
          "form": "circle",
          "dots": 4
        },
        {
          "form": "circle",
          "dots": 1
        },
        {
          "form": "circle",
          "dots": 3
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Circle with four dots",
        "correct": true
      },
      {
        "text": "Circle with five dots"
      },
      {
        "text": "Circle with three dots"
      },
      {
        "text": "Circle with two dots"
      }
    ]
  },
  "size-latin": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0017",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "square",
          "size": "small"
        },
        {
          "form": "square",
          "size": "medium"
        },
        {
          "form": "square",
          "size": "large"
        },
        {
          "form": "square",
          "size": "medium"
        },
        {
          "form": "square",
          "size": "large"
        },
        {
          "form": "square",
          "size": "small"
        },
        {
          "form": "square",
          "size": "large"
        },
        {
          "form": "square",
          "size": "small"
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Medium square",
        "correct": true
      },
      {
        "text": "Large square"
      },
      {
        "text": "Small square"
      },
      {
        "text": "Medium circle"
      }
    ]
  },
  "growing-turn": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0018",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
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
        },
        {
          "form": "square",
          "line": 0
        },
        {
          "form": "square",
          "line": 90
        },
        {
          "form": "square",
          "line": 180
        },
        {
          "form": "square",
          "line": 0
        },
        {
          "form": "square",
          "line": 135
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Line pointing left",
        "correct": true
      },
      {
        "text": "Line pointing down"
      },
      {
        "text": "Line pointing lower-right"
      },
      {
        "text": "Line pointing upper-right"
      }
    ]
  },
  "corner-grid": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0019",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "square",
          "dot": "top-left"
        },
        {
          "form": "square",
          "dot": "top-right"
        },
        {
          "form": "square",
          "dot": "bottom-right"
        },
        {
          "form": "square",
          "dot": "bottom-left"
        },
        {
          "form": "square",
          "dot": "top-left"
        },
        {
          "form": "square",
          "dot": "top-right"
        },
        {
          "form": "square",
          "dot": "bottom-right"
        },
        {
          "form": "square",
          "dot": "bottom-left"
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Square with dot at top-left",
        "correct": true
      },
      {
        "text": "Square with dot at bottom-right"
      },
      {
        "text": "Square with dot at bottom-left"
      },
      {
        "text": "Square with dot at top-right"
      }
    ]
  },
  "size-transfer": {
    "id": "q-spatial-abstract-reasoning-figure-matrices-0020",
    "figureSpec": {
      "kind": "figure-matrix",
      "rows": 3,
      "cols": 3,
      "cells": [
        {
          "form": "square",
          "size": "small",
          "dots": 1,
          "edgeLines": 3
        },
        {
          "form": "square",
          "size": "small",
          "dots": 2,
          "edgeLines": 2
        },
        {
          "form": "square",
          "size": "small",
          "dots": 3,
          "edgeLines": 1
        },
        {
          "form": "square",
          "size": "medium",
          "dots": 1,
          "edgeLines": 3
        },
        {
          "form": "square",
          "size": "medium",
          "dots": 2,
          "edgeLines": 2
        },
        {
          "form": "square",
          "size": "medium",
          "dots": 3,
          "edgeLines": 1
        },
        {
          "form": "square",
          "size": "large",
          "dots": 1,
          "edgeLines": 3
        },
        {
          "form": "square",
          "size": "large",
          "dots": 2,
          "edgeLines": 2
        },
        "blank"
      ]
    },
    "choices": [
      {
        "text": "Large square; three dots; one edge line",
        "correct": true
      },
      {
        "text": "Large square; three dots; two edge lines"
      },
      {
        "text": "Medium square; three dots; one edge line"
      },
      {
        "text": "Large square; two dots; one edge line"
      }
    ]
  }
}
''';
