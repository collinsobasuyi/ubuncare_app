
The overflowing RenderFlex has an orientation of Axis.horizontal.
The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and
black striped pattern. This is usually caused by the contents being too big for the RenderFlex.
Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the
RenderFlex to fit within the available space instead of being sized to their natural size.
This is considered an error condition because it indicates that there is content that cannot be
seen. If the content is legitimately bigger than the available space, consider clipping it with a
ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex,
like a ListView.
The specific RenderFlex in question is: RenderFlex#8766e relayoutBoundary=up8 OVERFLOWING:
  needs compositing
  creator: Row ← Column ← Padding ← DecoratedBox ← Container ← Column ← Padding ← FadeTransition ←
    MediaQuery ← Padding ← SafeArea ← KeyedSubtree-[GlobalKey#5e67a] ← ⋯
  parentData: offset=Offset(0.0, 37.0); flex=null; fit=null (can use size)
  constraints: BoxConstraints(0.0<=w<=253.0, 0.0<=h<=Infinity)
  size: Size(253.0, 74.0)
  direction: horizontal
  mainAxisAlignment: center
  mainAxisSize: max
  crossAxisAlignment: center
  textDirection: ltr
  verticalDirection: down
  spacing: 0.0
◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
════════════════════════════════════════════════════════════════════════════════════════════════════
Another exception was thrown: A RenderFlex overflowed by 172 pixels on the bottom.
Another exception was thrown: A RenderFlex overflowed by 99 pixels on the bottom.
Another exception was thrown: A RenderFlex overflowed by 99 pixels on the bottom.
Could not find a set of Noto fonts to display all missing characters. Please add a font asset for the
missing characters. See: https://flutter.dev/docs/cookbook/design/fonts
Another exception was thrown: A RenderFlex overflowed by 34 pixels on the bottom.
Another exception was thrown: A RenderFlex overflowed by 51 pixels on the bottom.
Another exception was thrown: A RenderFlex overflowed by 51 pixels on the bottom.
Another exception was thrown: A RenderFlex overflowed by 34 pixels on the bottom.
Another exception was thrown: A RenderFlex overflowed by 8.9 pixels on the bottom.