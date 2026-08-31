import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/figures/biology_diagram_figure.dart';
import 'package:pantas/core/ui/figures/chart_figure.dart';
import 'package:pantas/core/ui/figures/chemistry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/concept_diagram_figure.dart';
import 'package:pantas/core/ui/figures/coordinate_graph_figure.dart';
import 'package:pantas/core/ui/figures/cube_net_figure.dart';
import 'package:pantas/core/ui/figures/earth_science_diagram_figure.dart';
import 'package:pantas/core/ui/figures/figure_matrix_figure.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/figures/fluid_vessel_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/geometry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/lever_balance_figure.dart';
import 'package:pantas/core/ui/figures/paper_fold_figure.dart';
import 'package:pantas/core/ui/figures/physics_energy_diagram_figure.dart';
import 'package:pantas/core/ui/figures/physics_mechanics_diagram_figure.dart';
import 'package:pantas/core/ui/figures/pulley_system_figure.dart';
import 'package:pantas/core/ui/figures/reading_diagram_figure.dart';
import 'package:pantas/core/ui/figures/shape_row_figure.dart';
import 'package:pantas/core/ui/figures/spring_scale_figure.dart';
import 'package:pantas/core/ui/figures/stability_shape_figure.dart';

/// The only place that maps a content figure kind to its painter module.
abstract final class FigureRegistry {
  static Widget? build(Map<String, Object?> spec) {
    return switch (spec['kind']) {
      GearTrainFigure.kind => GearTrainFigure.fromSpec(spec),
      SpringScaleFigure.kind => SpringScaleFigure.fromSpec(spec),
      LeverBalanceFigure.kind => LeverBalanceFigure.fromSpec(spec),
      PulleySystemFigure.kind => PulleySystemFigure.fromSpec(spec),
      StabilityShapeFigure.kind => StabilityShapeFigure.fromSpec(spec),
      FluidVesselFigure.kind => FluidVesselFigure.fromSpec(spec),
      ShapeRowFigure.kind => ShapeRowFigure.fromSpec(spec),
      FigureSeriesFigure.kind => FigureSeriesFigure.fromSpec(spec),
      FigureMatrixFigure.kind => FigureMatrixFigure.fromSpec(spec),
      PaperFoldFigure.kind => PaperFoldFigure.fromSpec(spec),
      CubeNetFigure.kind => CubeNetFigure.fromSpec(spec),
      CoordinateGraphFigure.kind => CoordinateGraphFigure.fromSpec(spec),
      GeometryDiagramFigure.kind => GeometryDiagramFigure.fromSpec(spec),
      ChartFigure.kind => ChartFigure.fromSpec(spec),
      ConceptDiagramFigure.kind => ConceptDiagramFigure.fromSpec(spec),
      ReadingDiagramFigure.kind => ReadingDiagramFigure.fromSpec(spec),
      BiologyDiagramFigure.kind => BiologyDiagramFigure.fromSpec(spec),
      ChemistryDiagramFigure.kind => ChemistryDiagramFigure.fromSpec(spec),
      EarthScienceDiagramFigure.kind =>
        EarthScienceDiagramFigure.fromSpec(spec),
      PhysicsMechanicsDiagramFigure.kind =>
        PhysicsMechanicsDiagramFigure.fromSpec(spec),
      PhysicsEnergyDiagramFigure.kind =>
        PhysicsEnergyDiagramFigure.fromSpec(spec),
      _ => null,
    };
  }
}
