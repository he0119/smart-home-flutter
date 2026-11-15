# 界面规范

本文写给刚进这个仓库的人，以及后续要改界面的同学。目标只有一个：**同一个东西，在任何页面长得一样、用起来一样**，出了问题能一眼看出是哪段代码违反规范。

阅读顺序建议：先看第 0 节速查表，写页面时按第 2 节挑骨架，然后在第 6、7、8 节里找现成组件，最后对照第 11 节检查自己有没有踩坑。

几个词先说明，后面不再重复解释：

- **逻辑像素**：Flutter 里写 `56` 就是 56 个逻辑像素，不是物理像素。屏幕密度不同会等比放大，所以规范里只写数字不带单位。
- **主题（theme）**：`lib/app/theme.dart` 里给整套应用设的默认样式，输入框、按钮、卡片、弹窗、消息条都从这里来。
- **FAB**：右下角那个圆形悬浮按钮（`FloatingActionButton`）。
- **SnackBar**：从屏幕底部弹出来、几秒后自动消失的短消息条。
- **tooltip**：长按或鼠标悬停时出现的小提示。
- **sliver**：`CustomScrollView` 里可以滚动的片段，页面主体由一组 sliver 拼起来。
- **M3**：Material 3，Google 官方的一套界面设计规范，本项目全面采用。

---

## 0. 速查表：什么场景用哪个组件

| 你要做的事 | 用这个 | 位置 | 关键数字 |
| --- | --- | --- | --- |
| 一级 tab 页（物品 / 博客 / 留言板） | `MyHomePage` | `lib/widgets/home_page.dart` | 大标题 AppBar，FAB，宽屏侧边导航 |
| 二级页、表单页、搜索页 | `MySliverScaffold` + `appBarSize: AppBarSize.normal` | 同上 | 普通 AppBar，内容限宽 920 |
| 分组小标题 | `SectionHeader` | `lib/widgets/list_rows.dart` | `titleSmall` + 次要色，上 24 下 8 |
| 跳到别的页面的入口行 | `EntryRow` | 同上 | 主色圆底图标 40，尾部箭头，行高 56/72 |
| 列表里的一条内容 | `ContentRow` | 同上 | 浅底圆底图标 40，行高 56/72 |
| 详情页的「标签 / 值」 | `InfoRow` | 同上 | 上下各 12 内边距，值用 `bodyLarge` |
| 行与行之间的线 | `ContentDivider` | 同上 | 缩进 72，右侧留 16 |
| 列表底部留白 | `ListBottomPadding` | 同上 | 88 |
| 设置页的条目 | `SettingsTile` | `lib/widgets/settings/settings_tile.dart` | 无圆底图标，尾部箭头 |
| 设置页的分组 | `SettingsSection` + `SettingsList` | `lib/widgets/settings/` | 分组标题上 24 下 8 |
| 空列表 | `EmptyState` / `SliverEmptyState` | `lib/widgets/state_views.dart` | 图标圆 56，标题 `titleMedium` |
| 加载失败 | `ErrorState` / `SliverErrorState` | 同上 / `lib/widgets/state_views.dart` | 标题固定「加载失败」+ 重试 |
| 首次加载中 | `LoadingState` / `SliverCenterLoadingIndicator` | 同上 / `lib/widgets/center_loading_indicator.dart` | 转圈 32 |
| 下一页加载中 | `BottomLoader` | `lib/widgets/bottom_loader.dart` | 转圈 24，上下各 16 |
| 让用户确认一个动作 | `showConfirmDialog` | `lib/utils/show_confirm_dialog.dart` | 确认按钮写动词，危险操作红色 |
| 弹一条消息 | `showInfoSnackBar` / `showErrorSnackBar` | `lib/utils/show_snack_bar.dart` | 默认 4 秒，错误用红色底 |
| 长列表 + 滚动到底加载更多 | `SliverInfiniteList` | `lib/widgets/infinite_list.dart` | 提前 3 条请求下一页 |
| 单字段设置页 | `TextEditPage` | `lib/widgets/text_edit_page.dart` | 顶部勾号保存（例外，见 7.5） |
| 间距 / 圆角常量 | `AppSpacing` / `AppRadius` / `AppBreakpoints` | `lib/app/dimens.dart` | 4/8/12/16/24/32，圆角 8/12/16/28 |

**硬规则（评审会直接打回）**：页面代码里不出现 `Color(0x...)`、`Colors.xxx`、`fontSize: 数字`、`EdgeInsets.all(13)` 这类手写值。样式只从三处来：主题（`theme.dart`）、尺寸常量（`dimens.dart`）、公共组件（`lib/widgets/`）。

---

## 1. 设计原则

### 1.1 少而一致：一种标题、一种行、一种按钮

- **一种页面标题**：顶部 AppBar。页面正文里不要再写一遍大标题。
- **一种分组标题**：`SectionHeader`（列表场景）或 `SettingsSection` 的 `title`（设置场景），两者样式完全相同：`titleSmall` + `onSurfaceVariant`，上 24、下 8。
- **一种行**：全部走 Flutter 的 `ListTile` 家族。`EntryRow`、`ContentRow`、`SettingsTile` 内部都是 `ListTile`，所以行高、左缩进、点击波纹自动一致。不要用 `Container + InkWell + Row` 自己拼一行。
- **一种按钮**：主操作用填充按钮（`FilledButton`，项目里包了一层 `RoundedRaisedButton`），次要操作用 `TextButton`，介于两者之间的用 `OutlinedButton`。三者的高度、圆角、字号都由主题统一给出（48 高、12 圆角、`labelLarge`），页面里不要再写 `minimumSize` 或 `shape`。

为什么要这么严：这个项目的界面历史上是十几个页面各写各的，`是/否` 对话框有 11 套、空状态只有一行居中的灰字、同一类图标有 34 和 24 两种尺寸。统一之后才有「同一个应用」的感觉，也才敢批量改。

### 1.2 主色只给交互

`colorScheme.primary` 只允许出现在**用户能点、能聚焦、当前选中**的地方：

- FAB 的底色
- 填充按钮的底色
- 输入框聚焦时的 2 像素描边
- 加载转圈
- 进度、选中状态

不要用它给纯装饰的图标、标题、分隔线染色。唯一的例外是 `EntryRow`：它的图标用 `primaryContainer` 底色，因为这一行本身就是「点进去看更多」的入口，强调它是为了让人发现可点。这个例外只此一处，别扩散。

### 1.3 层级靠字号 + 颜色，不靠加粗和放大

一行文字只承担一个层级。要区分主次，用「`bodyLarge` + `onSurface`」对「`bodySmall` + `onSurfaceVariant`」，不要靠 `fontWeight: FontWeight.bold` 或 `fontSize: 18` 硬撑。

### 1.4 状态永远有三种，缺一个就是 bug

任何从网络取数据的页面，必须能同时表达：加载中、失败（可重试）、成功但为空。只写「成功」分支是最常见的问题 —— 用户分不清「真的没有」和「卡住了」。

---

## 2. 页面骨架

### 2.1 一级 tab 页：`MyHomePage`

只有三个页面是一级 tab：物品（`/storage`）、博客（`/blog`）、留言板（`/board`）。它们统一用 `MyHomePage`：

```dart
// lib/board/view/home_page.dart（节选，就是现在的写法）
return MyHomePage(
  title: AppTab.board.name, // '留言板'
  floatingActionButton: FloatingActionButton(
    tooltip: '添加话题',
    onPressed: () async { /* 打开新增页，返回 true 就刷新列表 */ },
    child: const Icon(Icons.create),
  ),
  slivers: [/* 状态 -> 列表 */],
  onRefresh: () async {
    ref.read(boardHomeProvider.notifier).fetch(cache: false);
  },
);
```

`MyHomePage` 会自动做四件事，页面里不用重复写：

1. 抽屉菜单（`MyDrawer`）。
2. 顶部 `SliverAppBar.medium` 大标题，滚动时收起成普通标题栏。
3. 宽度 ≥ 720（`AppBreakpoints.wide`）时，底部导航换成左侧 `NavigationRail`；窄屏用底部 `NavigationBar`。
4. 内容居中限宽 920。

### 2.2 二级页 / 表单页：`MySliverScaffold` + 普通 AppBar

除了三个一级 tab，**所有页面**都用 `MySliverScaffold`；表单页和搜索页要显式传 `appBarSize: AppBarSize.normal`：

```dart
// lib/storage/view/item_edit_page.dart:72
return MySliverScaffold(
  appBarSize: AppBarSize.normal, // 表单页必须写这一行
  title: widget.isEditing ? Text('编辑 ${widget.item!.name}') : const Text('添加物品'),
  sliver: SliverFillRemaining(hasScrollBody: false, child: /* 表单 */),
);
```

为什么必须写：`MySliverScaffold` 默认是 `AppBarSize.medium`（大标题）。表单页内容短，大标题没有可折叠的空间，会卡在「展开一半」的状态，看起来像没渲染完；搜索页的标题位放的是搜索框，放大标题也不合适。这两个场景在提交历史里都真出现过并被修过。

什么时候用 `normal`：

- 表单页（新增 / 编辑物品、位置、图片、话题、评论、耗材）
- 搜索页（标题位放 `SearchBar`）
- 任何传了 `appbarBottom` 的页面（代码里 `appbarBottom != null` 会自动切普通 AppBar，建议仍显式写出来，读代码的人不用去翻实现）

当前落实情况（新页面照这个对齐）：

| 页面 | 现状 |
| --- | --- |
| `item_edit_page.dart`、`storage_edit_page.dart`、`search_page.dart` | 已显式传 `normal`，可参照 |
| `topic_edit_page.dart`、`comment_edit_page.dart` | 有 `TabBar` 作为 `appbarBottom`，自动是普通 AppBar |
| `picture_add_page.dart`、`consumable_edit_page.dart` | 仍是大标题（medium），待收口，见 11.2 |

登录页是唯一不套骨架的页面：未登录时没有返回路径，也没有可切的一级 tab，所以用无 AppBar 的 `Scaffold`，内容居中、最宽 400、左右 16、底部整宽按钮：

```dart
SafeArea(
  child: Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          child: Column(spacing: AppSpacing.lg, children: [/* 图标、字段、整宽按钮 */]),
        ),
      ),
    ),
  ),
)
```

这些细节（`SafeArea`、限宽 400、整宽按钮）解决的是键盘弹起遮挡和小窗口下按钮点不到。其他页面不要照抄这套无 AppBar 的写法。

### 2.3 内容限宽 920

`MySliverScaffold` 默认 `contentMaxWidth: AppBreakpoints.contentMaxWidth`（920），宽屏下内容居中、两侧留白。**不要自己再包一层 `Center + ConstrainedBox`**，也不要为了「铺满」而把 920 改大。超过 920 之后列表被拉成一条横线，眼睛要从左扫到右，很难读。

### 2.4 页面主体的组装顺序

`slivers` 按固定顺序拼，读代码的人不用猜：

```dart
slivers: [
  if (state.status == XxxStatus.failure) SliverErrorState(...), // 1. 失败
  if (state.status == XxxStatus.loading) const SliverCenterLoadingIndicator(), // 2. 加载
  if (state.status == XxxStatus.success) SliverInfiniteList<T>(...), // 3. 内容
  if (state.status == XxxStatus.success)
    const SliverToBoxAdapter(child: ListBottomPadding()), // 4. 给 FAB 留白
],
```

失败和加载两种状态是 `SliverFillRemaining`（铺满剩余空间并居中），所以它们的判断要写在内容之前。

### 2.5 下拉刷新

`onRefresh` 传了函数才有下拉刷新，内部用 `RefreshIndicator`，`edgeOffset: 56`（避开 AppBar）。不要自己再包一层 `RefreshIndicator`。

```dart
onRefresh: () async {
  ref.read(recycleBinProvider.notifier).fetch(cache: false); // 刷新必须绕过缓存
},
```

### 2.6 返回行为

要在返回前做拦截（比如首页从筛选态回退到全部物品），用 `canPop` + `onPopInvokedWithResult`，不要自己塞 `WillPopScope`。

---

## 3. 间距与圆角

尺寸常量只有两个来源：`AppSpacing`（间距）和 `AppRadius`（圆角），都在 `lib/app/dimens.dart`。

### 3.1 间距 `AppSpacing`

| 常量 | 值 | 用在哪 |
| --- | --- | --- |
| `AppSpacing.xs` | 4 | 同一行内紧邻的两个元素：`InfoRow` 里标签和值的间距、chip 上下内边距、排序菜单图标和文字之间 |
| `AppSpacing.sm` | 8 | 分组标题的下边距、列表行的上下贴边、卡片上下外边距、搜索页 chip 区左右内边距 |
| `AppSpacing.md` | 12 | **表单字段之间的间距**、`InfoRow` 上下内边距、状态页转圈和说明之间、并排两个按钮之间 |
| `AppSpacing.lg` | 16 | **页面左右内边距**、列表行左右内边距、分隔线右端留白、状态页图标和标题之间 |
| `AppSpacing.xl` | 24 | 分组标题的上边距（分组之间靠它隔开）、对话框四周留白、状态页整体内边距 |
| `AppSpacing.xxl` | 32 | 少见，仅用于页面级大块留白 |

三条落地规则：

1. **同一组内用 8 / 12，组与组之间用 24，页面左右用 16。**
2. 不要出现 5、7、13、20、33 这类数字。历史提交里专门清过 `BottomLoader` 的 `33/1.5` 魔法数。
3. 纵向排列的字段，用 `Column(spacing: AppSpacing.md)` 一把设完，不要每个字段后面塞一个 `SizedBox(height: 12)`。

### 3.2 圆角 `AppRadius`

| 常量 | 值 | 用在哪 |
| --- | --- | --- |
| `AppRadius.sm` | 8 | chip、路径栏里可点的位置名 |
| `AppRadius.md` | 12 | 输入框、所有按钮、SnackBar |
| `AppRadius.lg` | 16 | 卡片 |
| `AppRadius.xl` | 28 | 对话框、底部弹层（只圆上边两个角） |

圆角一律交给主题（`theme.dart` 里已经设好）。页面里出现 `BorderRadius.circular(20)`、`RoundedRectangleBorder(...)` 就是重复劳动，评审会问「为什么主题不够用」。

### 3.3 固定尺寸清单（不要再发明）

这些数字是组件内部约定，改它们等于改全站观感，先讨论再动：

| 数字 | 含义 | 出处 |
| --- | --- | --- |
| 40 | 列表行图标圆的直径（`radius: 20`） | `list_rows.dart` |
| 20 | 圆里的图标大小 | 同上 |
| 72 | 分隔线缩进（16 左边距 + 40 图标 + 16 间隙） | `ContentDivider.indent` 默认值 |
| 56 / 72 | 列表行高度：单行 / 带副标题 | `ListTile` 默认值，不要手写 `height` |
| 88 | 列表底部留白（56 FAB + 16 底距 + 16 呼吸） | `ListBottomPadding.height` 默认值 |
| 56 | 空状态、错误状态的图标圆直径；圆内图标 28 | `state_views.dart` |
| 320 | 状态页文字最大宽度 | 同上 |
| 48 | 按钮最小高度（`TextButton` 为 44）、图标按钮点击区 | `theme.dart` |
| 32 / 24 | 整页转圈 / 列表底部转圈 | `state_views.dart` / `bottom_loader.dart` |
| 48 | 位置详情页顶部路径栏高度 | `PathBarDelegate.maxExtent` |
| 56 | 下拉刷新的 `edgeOffset` | `home_page.dart` |
| 920 / 720 | 内容最大宽度 / 宽屏断点 | `AppBreakpoints` |

---

## 4. 颜色

只有一个入口：`Theme.of(context).colorScheme`。所有颜色都要带语义名，因为暗色模式下值会变、系统动态取色时值也会变，写死就一定出错。

| 颜色角色 | 用在哪 | 代码 |
| --- | --- | --- |
| `onSurface` | 正文、行标题、`InfoRow` 的值、路径栏里的当前项、`ElevatedButton` 文字 | `colorScheme.onSurface` |
| `onSurfaceVariant` | 副标题、分组标题、说明文字、无强调的图标、尾部箭头、未选中项、`InfoRow` 的标签 | `colorScheme.onSurfaceVariant` |
| `primary` | FAB 底色、填充按钮底色、输入框聚焦描边、加载转圈 | 由主题自动套用 |
| `primaryContainer` / `onPrimaryContainer` | `EntryRow` 的图标圆底、抽屉头部的底色和文字 | 同上 |
| `secondaryContainer` | 选择器里当前选中那一行的底色 | `storage_picker_sheet.dart` |
| `surface` | AppBar 底色、吸顶分组标题的底色（用来盖住下面滚动的内容） | 主题已设 |
| `surfaceContainerLow` | 卡片、底部弹层 | 主题已设 |
| `surfaceContainerHigh` | 对话框、`ElevatedButton` 底色 | 主题已设 |
| `surfaceContainerHighest` | 输入框填充底、`ContentRow` 图标圆底、空状态图标圆底 | 主题已设 |
| `error` / `onError` | 危险操作按钮、错误 SnackBar 的底色和文字 | `showConfirmDialog(destructive: true)` |
| `errorContainer` / `onErrorContainer` | 错误状态的图标圆底 | `state_views.dart` |
| `outlineVariant` | 所有分隔线 | 主题已设 |

### 4.1 禁止的写法

```dart
// 反例
Text('全部评论', style: const TextStyle(fontSize: 16, color: Colors.black))
Container(color: Colors.grey[200])
Icon(Icons.error, color: Colors.red)
Text('提示', style: TextStyle(color: Theme.of(context).primaryColor)) // primaryColor 已废弃
```

```dart
// 正确
Text('全部评论', style: Theme.of(context).textTheme.titleSmall)
Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)
Icon(Icons.error, color: Theme.of(context).colorScheme.onErrorContainer)
Text('提示', style: Theme.of(context).textTheme.bodySmall!.copyWith(
  color: Theme.of(context).colorScheme.onSurfaceVariant,
))
```

整个仓库唯一允许的字面量颜色是 `lib/app/theme.dart` 里的 `brandSeedColor = Color(0xFF6750A4)`（取不到系统动态取色时用它生成整套配色），以及 `@Preview` 预览函数里为了不依赖应用入口而临时建的 `ColorScheme`。其余一律不许。

### 4.2 用颜色表达含义，要配文字

- 「删除」用红色按钮，同时按钮上写「删除」，不能只靠颜色。
- 「选中」用 `secondaryContainer` 底，同时右侧打勾。
- 「出错」用红色，同时写清什么错了、能不能重试。

---

## 5. 字体层级

字号和字重全部走 `Theme.of(context).textTheme`，下表是唯一允许的组合。

| 层级 | 用的样式 | 场景 | 谁在用 |
| --- | --- | --- | --- |
| 页面标题 | AppBar 内部（medium 展开 `headlineSmall`、收起 `titleLarge`；normal 为 `titleLarge`） | 每个页面顶部 | `MyHomePage` / `MySliverScaffold`，**页面里不要再写** |
| 页内大标题 | `headlineSmall` | 详情页正文里的标题（话题标题） | `topic_item.dart` 的 `showBody: true` 分支 |
| 分组标题 | `titleSmall` + `onSurfaceVariant` | 「过期物品」「基本信息」「通用」 | `SectionHeader`、`SettingsSection` |
| 行标题 | `bodyLarge` | 列表行主文字 | `ListTile` 默认；`EntryRow.title` 显式指定 |
| 行副标题 | `bodyMedium` + `onSurfaceVariant` | 时间、位置、作者、数量 | `EntryRow.supporting`；`ListTile.subtitle` 默认 |
| 标签 | `bodySmall` + `onSurfaceVariant` | `InfoRow` 上面的小字标签 | `InfoRow.label` |
| 值 | `bodyLarge` | `InfoRow` 下面的值 | `InfoRow` 内 `DefaultTextStyle.merge` |
| 说明 / 时间 / 空态说明 | `bodySmall` + `onSurfaceVariant` | 空状态的一句话说明、加载说明 | `state_views.dart` |
| 按钮 / chip 文字 | `labelLarge` | 所有按钮、chip | 主题统一，**不要给按钮写 `textStyle`** |
| 状态页标题 | `titleMedium` | 「没有找到相关内容」「加载失败」 | `_StateLayout` |
| 对话框标题 / 正文 | `headlineSmall` / `bodyMedium` | 确认框 | `AlertDialog` 默认，不用改 |

示例（`InfoRow` 内部就是这个组合，页面里直接用组件即可，不必自己拼）：

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    )),
    const SizedBox(height: AppSpacing.xs),
    Text(value, style: theme.textTheme.bodyLarge),
  ],
)
```

### 5.1 反例

```dart
// 反例 1：用字号造层级（现存于话题详情「全部评论」一行）
const Text('全部评论', style: TextStyle(fontSize: 16))
// 改成
Text('全部评论', style: Theme.of(context).textTheme.titleSmall)

// 反例 2：给输入框提示语写死字号（现存于话题 / 评论编辑页）
hintStyle: TextStyle(fontSize: 18)
// 改成：删掉这段，主题里的 hintStyle 已经是 onSurfaceVariant 的 bodyMedium

// 反例 3：一行字既放大又加粗，还换了个颜色
Text('备注', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey))
```

唯一允许的例外是「当前项」的强调：位置详情页路径栏的当前位置用 `bodyMedium` + `FontWeight.w600`，因为要让用户一眼看到自己在哪一层。这类例外出现时，在代码里写一行注释说明理由。

---

## 6. 列表

### 6.1 四种行，别混用

| 组件 | 用在什么场景 | 图标 | 尾部 | 行高 |
| --- | --- | --- | --- | --- |
| `EntryRow` | 跳到另一个页面的入口（首页「所有位置」） | `primaryContainer` 圆底 40，图标 20 | 默认箭头 `chevron_right` | 56 / 72 |
| `ContentRow` | 具体对象的列表行（物品、位置、耗材、图片） | `surfaceContainerHighest` 圆底 40，图标 20 | 自己传：一段量值、一个按钮，或不传 | 56 / 72 |
| `InfoRow` | 详情页的「标签—值」 | 无图标 | 可选箭头 + 可点 | 由内容决定，单行约 68 |
| `SettingsTile` | 设置页的条目；副标题过长用 `subtitleMaxLines: 2`，默认 1 行加省略号 | 纯图标，`onSurfaceVariant`，默认 24 | 有 `onPressed` 时自动加箭头 | 56 / 72 |

判断口诀：**能点进去看更多 → `EntryRow`；列表里的一个东西 → `ContentRow`；描述一个东西的属性 → `InfoRow`；改一个开关或选项 → `SettingsTile`。**

`TopicItem`、`ItemTitle` 这类带头像的社交行直接用 `ListTile` + `MyCircleAvatar`，不用上面四个（头像不是功能图标，不该套圆底色）。

### 6.2 行高 56 / 72

- 只有标题：56。
- 标题 + 副标题：72。
- 不要写 `SizedBox(height: ...)`，也不要给 `ListTile` 传 `minVerticalPadding` 去微调。

历史上出现过「行高变成 72、但只有一行字」的问题，原因是把空字符串当副标题传进去：

```dart
// 反例
ContentRow(
  icon: Icons.inventory_2_outlined,
  title: Text(item.name),
  supporting: Text(item.description ?? ''), // 描述为空时是空字符串，照样占第二行
)

// 正确
ContentRow(
  icon: Icons.inventory_2_outlined,
  title: Text(item.name),
  supporting: (item.description?.isEmpty ?? true) ? null : Text(item.description!),
)
```

拼副标题时用 `join(' · ')` 把多段信息压成一行，这也是全站习惯：

```dart
final supporting = <String>[
  if (time.isNotEmpty) time,
  if (storageName != null && storageName.isNotEmpty) storageName,
].join(' · '); // '3 天后过期 · 厨房吊柜'
```

### 6.3 分隔线

- 用 `ContentDivider`（默认 `indent: 72`、`endIndent: 16`）。缩进到图标右侧，是为了不让一列分隔线和一列图标连成竖条。
- 只在两行之间插，最后一行后面不要有线。用 `SliverInfiniteList` 的 `separatorBuilder` 就自动满足：

```dart
SliverInfiniteList<Item>(
  items: state.items,
  separatorBuilder: (context, item) => const ContentDivider(),
  itemBuilder: (context, item) => ContentRow(...),
  hasReachedMax: state.hasReachedMax,
  onFetch: () => ref.read(recycleBinProvider.notifier).fetch(),
)
```

- 不要用裸 `Divider()`：它从最左边起画，和图标列对不齐，看上去比标题还靠外。旧组件 `InfiniteList` 里就是无条件插 `Divider()`（最后一行后面也有一条），新页面统一用 `SliverInfiniteList`，不要再用 `InfiniteList`。

### 6.4 一行只放一个操作

`trailing` 只能放一样东西：一个箭头、一个图标按钮，或一段量值文字。

```dart
// 正确：回收站放「恢复」一个操作
ContentRow(
  icon: Icons.inventory_2_outlined,
  title: Text(item.name),
  supporting: Text(supporting),
  trailing: IconButton(
    tooltip: '恢复',
    icon: const Icon(Icons.undo),
    onPressed: () { /* 先确认再恢复 */ },
  ),
)
```

```dart
// 反例：一行里塞两个图标按钮，手机上会挤到标题折两行
trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(...), IconButton(...)])
```

第二个及以上的操作收进 `PopupMenuButton`，和位置详情、物品详情、话题详情页顶部菜单的做法一致。

### 6.5 加载更多：只用转圈，不用箭头

- 列表到底部、还有下一页时，底部显示 `BottomLoader`（24 转圈 + 读屏提示「正在加载更多」），由 `SliverInfiniteList` 自动插入，页面不用管。
- 判断「要不要请求下一页」的阈值由组件给：`invisibleItemsThreshold: 3`，即倒数第 3 条开始构建时就请求，用户滚到时数据已到位。
- **不要**写「加载更多」「查看更多」文字按钮，**不要**用尾部箭头 `chevron_right` 或 `expand_more` 表示还有更多 —— 箭头在这个应用里的含义固定是「点进去」。

### 6.6 顺序与高亮

- 位置和物品混排时，位置在前、物品在后（`StorageItemList` 的合并顺序），因为位置是容器、物品在容器里。
- 搜索关键词高亮用 `SubstringHighlight`：命中部分换 `primary` + `w600`，不加背景色块。早先的红底高亮已被移除，别加回来（红色在这个应用里固定表示错误）。

### 6.7 完整列表页骨架

```dart
return MySliverScaffold(
  appBarSize: AppBarSize.normal, // 二级页
  title: const Text('回收站'),
  onRefresh: () async {
    ref.read(recycleBinProvider.notifier).fetch(cache: false);
  },
  slivers: [
    if (state.status == RecycleBinStatus.failure)
      SliverErrorState(
        message: state.errorMessage,
        onPressed: () => ref.read(recycleBinProvider.notifier).fetch(cache: false),
      ),
    if (state.status == RecycleBinStatus.loading) const SliverCenterLoadingIndicator(),
    if (state.status == RecycleBinStatus.success && state.items.isEmpty)
      const SliverEmptyState(
        icon: Icons.delete_outline,
        title: '回收站是空的',
        message: '删除的物品会先放到这里，之后还能恢复',
      ),
    if (state.status == RecycleBinStatus.success && state.items.isNotEmpty)
      SliverInfiniteList<Item>(/* ... */),
  ],
);
```

---

## 7. 表单

### 7.1 骨架

```dart
// 结构参考 lib/storage/view/storage_edit_page.dart:122
return MySliverScaffold(
  appBarSize: AppBarSize.normal,
  title: widget.isEditing ? Text('编辑 ${widget.storage!.name}') : const Text('添加位置'),
  sliver: SliverFillRemaining(
    hasScrollBody: false, // 内容短时也铺满，键盘弹起时不溢出
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: AppSpacing.md, // 字段间距 12，一把设完
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '名称'),
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => value!.isEmpty ? '名称不能为空' : null,
              textInputAction: TextInputAction.next,
              focusNode: _nameFocusNode,
              onFieldSubmitted: (_) => _fieldFocusChange(context, _nameFocusNode, _descriptionFocusNode),
            ),
            // ... 其余字段
            SizedBox(
              width: double.infinity, // 底部按钮整宽
              child: RoundedRaisedButton(
                onPressed: state.status != StorageEditStatus.loading
                    ? () {
                        if (_formKey.currentState!.validate()) _onSubmitPressed();
                      }
                    : null, // 提交中禁用，防重复提交
                child: const Text('提交'),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
```

要点：

1. **左右 16**（`AppSpacing.lg`），靠 `Padding` 给，不要在 `Form` 外包 `Card`。
2. **字段间距 12**（`Column(spacing: AppSpacing.md)`）。早先字段是贴在一起的，后来专门修过。
3. **底部按钮整宽**（`SizedBox(width: double.infinity)`），高度 48 由主题给。主按钮文案用动词：「提交」「上传」「登录」，不用「确定」。
4. **提交中禁用按钮**，不要靠 `bool _submitting` 自己记状态，直接看 provider 的 `status`。

### 7.2 输入框只能有一种

样式全部来自 `theme.dart`，页面里只写 `decoration: InputDecoration(labelText: '…')`：

- 浅底填充（`surfaceContainerHighest`）+ 12 圆角 + 平时无边框。
- 聚焦时 `primary` 2 像素描边，出错时 `error` 2 像素描边。
- 内边距 左右 16 / 上下 14。
- 提示文字（hint）和标签（label）用 `onSurfaceVariant`。

```dart
// 反例：自己写边框，还会把浮动标签压住
decoration: InputDecoration(
  border: OutlineInputBorder(),          // 主题已换成 UnderlineInputBorder
  fillColor: Colors.white,
  filled: true,
  hintStyle: TextStyle(fontSize: 18),    // 字号写死
)

// 正确
decoration: const InputDecoration(labelText: '名称'),
```

为什么边框必须是 `UnderlineInputBorder`：`OutlineInputBorder` 的描边会画在填充色上层，浮动标签正好压在那条线上，标签上半截被盖住。这是真机上发现的 bug，别再改回去。

其他字段类型：

- 选择器（存放位置）：`StorageFormField`，样式已和文本框对齐。
- 日期：`DateTimePickerFormField`。
- 长文本（话题正文）：`maxLines: null`，不要给固定高度。

### 7.3 键盘与焦点

- 每个 `TextFormField` 给 `textInputAction: TextInputAction.next`，最后一个给 `TextInputAction.done`。
- 用 `onFieldSubmitted` + `FocusNode` 把焦点串到下一个字段，参考 `item_edit_page.dart` 的 `_fieldFocusChange`。
- 页面上有搜索框时，`onTapOutside` 收起键盘。

### 7.4 校验

- `autovalidateMode: AutovalidateMode.onUserInteraction`：用户碰过才报错，不要一进页面就满屏红字。
- 校验文案说人话：「名称不能为空」「请选择一个存放位置」「网址必须为 http:// 或 https:// 开头」。
- 长度上限用 `LengthLimitingTextInputFormatter`，和后端字段长度对齐（当前统一 200）。

### 7.5 AppBar 保存按钮：只允许在单字段设置页

```dart
// lib/widgets/text_edit_page.dart（节选）
return MySliverScaffold(
  title: Text(widget.title),
  actions: <Widget>[
    IconButton(
      tooltip: '保存',
      icon: const Icon(Icons.check),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          widget.onSubmit(_textController.text);
          Navigator.of(context).pop();
        }
      },
    ),
  ],
  sliver: SliverToBoxAdapter(child: /* 一个输入框 + 一句说明 */),
);
```

适用条件（三条都满足才用）：只有一个字段、改动即时生效、用户改完就要走。典型是设置页里的「服务器网址」「博客网址」。

其余情况一律用底部整宽按钮：多字段表单里，用户看不到顶部那个勾，会以为没法保存。

---

## 8. 状态：空、错、加载

### 8.1 三个组件

| 组件 | 用在 | 结构 |
| --- | --- | --- |
| `EmptyState` / `SliverEmptyState` | 成功但没数据 | 图标圆 56（`surfaceContainerHighest`）+ `titleMedium` 标题 + `bodySmall` 说明 + 可选一个操作 |
| `ErrorState` / `SliverErrorState` | 加载失败 | `cloud_off_outlined` 图标（`errorContainer` 底）+ 标题「加载失败」+ 真实错误信息 + 「重试」按钮 |
| `LoadingState` / `SliverCenterLoadingIndicator` | 首次加载 | 32 转圈 + 可选 `bodySmall` 说明 |

`CenterMessage` / `SliverCenterMessage` / `ErrorMessageButton` 都已删除，等价写法分别是 `EmptyState` 和 `ErrorState`。旧代码里如果还看到这几个名字，说明是从旧版本拷过来的，直接换掉。

### 8.2 空态文案规则

三段式：**是什么没有 + 为什么 + 下一步能做什么**。标题短、说明具体。

```dart
// 好
const SliverEmptyState(
  icon: Icons.search_off,
  title: '没有找到相关内容',
  message: '换个关键字试试，或者关掉筛选条件',
)

// 好：区分「还没搜」和「搜了没有」
const SliverEmptyState(
  icon: Icons.search,
  title: '搜索物品和位置',
  message: '输入名称或备注里的关键字',
)
```

```dart
// 差：只有结论，用户不知道下一步
Center(child: Text('暂无数据'))
// 差：空态和加载态长得一样，用户以为卡住了
Center(child: Text('加载中...'))
```

图标选择：空列表 `inbox_outlined`（默认）、搜索无结果 `search_off`、没图片 `image_outlined`、回收站 `delete_outline`。图标只是辅助，别花时间挑。

### 8.3 错误态规则

- 标题固定「加载失败」，不要每页换说法（比如「出错了」「网络错误」）。
- `message` 传真实错误信息（`state.errorMessage`），不要吞掉换成「请稍后重试」。用户报 bug 时这句话就是线索。
- 一定有「重试」按钮，而且重试要绕过缓存（`fetch(cache: false)` 或 `refresh()`），否则点一次还是同样的缓存结果。

### 8.4 加载态规则

- 整页首次加载：`SliverCenterLoadingIndicator`。
- 列表下一页：`BottomLoader`（组件自动插入）。
- 局部操作（上传图片、提交表单）：SnackBar「正在提交...」+ 按钮禁用，**不要**给整个页面盖一层遮罩转圈。

```dart
// 页面里的状态分支（参考 lib/storage/view/search_page.dart 的 Consumer）
if (state.status == SearchStatus.loading) return const SliverCenterLoadingIndicator();
if (state.status == SearchStatus.failure) return SliverErrorState(message: state.errorMessage);
if (state.status == SearchStatus.success) {
  if (state.items.isEmpty && state.storages.isEmpty) {
    return const SliverEmptyState(icon: Icons.search_off, title: '没有找到相关内容', message: '换个关键字试试，或者关掉筛选条件');
  }
  return StorageItemList(items: state.items, storages: state.storages, isHighlight: true, term: state.term);
}
return const SliverEmptyState(icon: Icons.search, title: '搜索物品和位置', message: '输入名称或备注里的关键字');
```

---

## 9. 弹窗与提示

### 9.1 确认框：一律用 `showConfirmDialog`

```dart
final confirmed = await showConfirmDialog(
  context,
  title: '删除 ${item.name}',            // 动作 + 对象
  message: '删除后可以在回收站里找回，确认删除？', // 说清后果
  confirmLabel: '删除',                  // 动词，不是「确定」
  destructive: true,                    // 危险操作用红底
);
if (!confirmed) return;
```

规则：

1. **`title` 写「动作 + 对象」**：「删除 阳台储物柜」「登出」「置顶话题」。不要写「提示」「确认操作」。
2. **`confirmLabel` 必须是动词**：「删除」「恢复」「登出」「置顶」「关闭」。用户扫一眼按钮就知道会发生什么，不用回想上面问了什么。
3. **`destructive: true` 只给不可挽回或影响面大的操作**：删除、登出、清理。这时确认按钮用 `error` 底 + `onError` 字。置顶、关闭话题这类可逆操作传 `false`。
4. **`message` 写后果**，不是重复标题。「删除后无法恢复，确认删除这个话题？」「删除后可以在回收站里找回，确认删除？」两者的区别就是用户唯一关心的信息。
5. **顺序固定**：左边「取消」（`TextButton`），右边确认（`FilledButton`）。取消要能被肌肉记忆点到。
6. 不要在页面里自己写 `showDialog` + `AlertDialog` + 两个按钮，除非是做选择器（比如存放位置选择器，那种是「选一个值」，不是「确认一个动作」）。

### 9.2 消息条：`showInfoSnackBar` / `showErrorSnackBar`

| 函数 | 外观 | 默认时长 | 用在哪 |
| --- | --- | --- | --- |
| `showInfoSnackBar(msg)` | 反色底（亮色主题下是深色底、浅色字）+ 12 圆角 | 4 秒 | 操作成功 |
| `showErrorSnackBar(msg)` | `error` 底、`onError` 字 | 4 秒 | 操作失败，`msg` 传真实错误 |

时长按语义选：

- **1 秒**：「正在提交...」「正在删除...」。它是「我收到了，正在做」的即时反馈，马上会被结果覆盖。
- **2 秒**：「物品 xx 恢复成功」这类结果，紧跟在上一条 1 秒提示之后。
- **4 秒（默认）**：普通成功提示。

规则：

1. SnackBar 只报结果，不承载需要用户决策的内容。要用户选「删不删」，用确认框。
2. 不要在 SnackBar 里放「撤销」按钮。真要做撤销，就做个真能用的撤销（回收站），别给一个点了没反应的按钮。
3. 文案带对象名：「物品 螺丝刀 添加成功」，不要只写「操作成功」。
4. 错误必须走 `showErrorSnackBar`，别用 `showInfoSnackBar` 假装成功。红色是用户唯一能快速识别的信号。

### 9.3 底部弹层与对话框（选择器）

- 窄屏（宽度 < 600）用 `showModalBottomSheet`（`isScrollControlled: true`，顶部圆角 28，自带拖动条）。
- 宽屏（≥ 600）用 `showDialog`（四周留白 24，圆角 28）。
- 两边共用同一份内容组件，只在容器上分叉，参考 `lib/storage/view/widgets/storage_picker_sheet.dart`。
- 选中态：`secondaryContainer` 底 + 右侧打勾，不要只换文字颜色。

---

## 10. 无障碍

### 10.1 图标按钮必须有说明

```dart
// 正确：一处 tooltip，同时给鼠标悬停和读屏
IconButton(
  tooltip: '恢复',
  icon: const Icon(Icons.undo),
  onPressed: onRestore,
)
```

```dart
// 反例：外层再套一层 Tooltip，和里面的 tooltip 重复
Tooltip(
  message: '搜索',
  child: IconButton(tooltip: '搜索', icon: const Icon(Icons.search), onPressed: ...),
)
```

仓库里还有几处这种双写：`share_icon_button.dart:14,17`、`scan_qr_icon_button.dart:14,17`、`add_storage_icon_button.dart:14,20`、`mipush_page.dart:28,32`、`text_edit_page.dart:50,53`、`topic_edit_page.dart:65,68`、`comment_edit_page.dart:68,71`。属于历史写法，改到那个文件时顺手删掉外层 `Tooltip`，不用专门开 PR。`search_icon_button.dart` 只有外层 `Tooltip`、没有内层 `tooltip`，功能上能读出来，但建议统一成内层写法。

tooltip 文案写**动作**（「搜索」「添加物品」「恢复」「编辑」），不是图标名（「放大镜」「加号」）。

### 10.2 点击区至少 48 × 48

- `IconButton` 默认就是 48 × 48，直接用，不要用 `SizedBox(width: 24)` 把它压小。
- 自己用 `InkWell` 包图标时，必须补足 48：`constraints: const BoxConstraints(minWidth: 48, minHeight: 48)`。
- 列表行的点击区由 `ListTile` 保证（整行可点，高 56/72）。
- chip 外面有 4 / 8 的内边距（`MyChoiceChip`），别去掉，否则手指容易点错。

### 10.3 读屏

- 纯图标的地方要有语义标签：`BottomLoader` 用 `Semantics(label: '正在加载更多')`，照这个写。
- 纯装饰的图标（`EntryRow`、`ContentRow` 前面的圆底图标）只要用 `Icon` 且不传 `semanticLabel`，本身就不会进语义树，读屏只会念标题。自己拼 `Row` 时如果用了 `Image.asset` 之类的装饰图，记得包 `ExcludeSemantics`。
- 有信息量的图片要有替代说明（`Image` 的 `semanticLabel`），比如二维码。纯装饰的头像可以不给。
- 头像 + 用户名 + 时间这种组合，读屏顺序要自然（头像 → 用户名 → 时间），不要中间插一个纯装饰的锁图标。

### 10.4 其他

- 字号全部走 `textTheme`，跟随系统字体缩放。不要用 `FittedBox` 把长文案压小，宁可折行。
- 颜色不能是唯一的信息载体（见 4.2）。
- `onSurfaceVariant` 只用于次要信息；如果把主要标题调成这个颜色，弱视用户会读不清。
- 表格、按钮、输入框都要能用键盘操作到底（Web / Windows 端），别用 `GestureDetector` 替代 `InkWell` / `ListTile`，后者才有焦点和波纹。

---

## 11. 反例清单

### 11.1 通用反例

| 反例 | 为什么错 | 正确做法 |
| --- | --- | --- |
| `Color(0xFFF15713)`、`Colors.grey[200]` | 暗色模式下不可读；换主题时不跟着变 | `colorScheme.xxx` 语义色 |
| `fontSize: 16` / `fontWeight: bold` 造层级 | 系统字体缩放时会和别处不一致 | `textTheme.titleSmall` 等 |
| `EdgeInsets.all(13)`、`SizedBox(height: 20)` | 间距失去节奏，改一处要改十处 | `AppSpacing.md` 等 |
| `Card` 里再套 `Card`，或 `Card` 里放 `ListTile` | 内外两层各 16 缩进，图标比下面列表右移 16，整列对不齐（首页「所有位置」入口真出过这个问题） | 一整块内容直接放 `ListTile`，不要 `Card` 包 |
| 一行 `trailing` 放两个以上按钮 | 手机上标题被挤成两行，点错率高 | 多的收进 `PopupMenuButton` |
| 用 `chevron_right` / `expand_more` 表示「还有更多」 | 这个应用里箭头固定表示「点进去」 | 加载更多用 `BottomLoader` 转圈 |
| 页面正文再写一遍页面标题 | 大标题 + 正文标题重复，浪费首屏 | 标题只在 AppBar |
| 空字符串当副标题 | 行高从 56 变 72，留一片空白 | 传 `null` |
| 空态只写「暂无数据」 | 用户分不清是没有还是没加载完 | 标题 + 说明 + 可选操作 |
| 给 `FilledButton` 写 `shape` / `minimumSize` | 主题已统一 48 高 12 圆角 | 删掉，交给主题 |
| 给每个字段后面塞 `SizedBox(height: 12)` | 调整间距要改 N 处 | `Column(spacing: AppSpacing.md)` |
| `showDialog` 手写「是 / 否」 | 每个页面叫法不同，用户要想「刚才问的是什么」 | `showConfirmDialog(confirmLabel: '删除')` |
| 用 SnackBar 问「要不要删除」 | 会自己消失，用户来不及点 | 确认框 |
| `RefreshIndicator` 套两层 | 下拉出两个圈 | 只用 `MySliverScaffold.onRefresh` |
| 页面里再包 `Center + ConstrainedBox(920)` | 限宽已在骨架里 | 删掉 |
| 自己拼 `Container + InkWell + Row` 当列表行 | 行高、波纹、点击区、读屏全要重写 | `ContentRow` / `EntryRow` / `SettingsTile` |

### 11.2 本轮已收口的共性问题

这些坑在本轮统一改造里已经修掉，写新页面时按这里的方式做，不要退回旧写法：

| 主题 | 错误写法 | 现在统一为 |
| --- | --- | --- |
| 错误态 | `SliverErrorMessageButton` / `ErrorMessageButton` | `SliverErrorState(onRetry:, message:)` / `ErrorState` |
| 空态 | 手写 `Center > Column`、裸 `ListTile(title: Text('无数据'))` | `EmptyState` / `SliverEmptyState`，文案写「是什么没有 + 为什么 + 下一步」 |
| 图标按钮提示 | 外层 `Tooltip` 再包一个带 `tooltip:` 的 `IconButton` | 只用 `IconButton.tooltip`，否则读屏会念两遍 |
| 列表分隔线 | 每个 item 底部都画一条 `Divider` | `SliverInfiniteList(separatorBuilder: ...)` 或 `ContentDivider`，最后一行后面不留线 |
| 表单按钮 | `Center(child: FilledButton(...))`、带箭头的「下一步」 | 底部 `SizedBox(width: double.infinity)` 整宽主按钮 |
| 表单输入框 | `border: InputBorder.none` + 写死 `hintStyle: TextStyle(fontSize: 18)` | 交给主题：填充 + 圆角，`InputDecoration(labelText:, hintText:)` |
| 表单页 AppBar | 忘传 `appBarSize`，得到大标题 | `appBarSize: AppBarSize.normal` |
| 表单边距 | `EdgeInsets.only(left: 16, right: 16)`、`EdgeInsets.all(8)` | `fromLTRB(lg, md, lg, xl)` + `SafeArea(top: false)` |
| 列表底部 | `SizedBox(height: 88)` | `ListBottomPadding()` |
| 设置行副标题 | 长 URL 不限制行数，把行撑高 | `SettingsTile(subtitleMaxLines: 1)`，错误信息传 2 |
| 单选勾 | 各页复制一份 `Icon(Icons.check, color: secondary)` / `Icon(null)` 占位 | `SelectionCheck(selected:)`，颜色用 `primary` |
| 分组标题 | 各页自己写 `Padding + titleSmall` | `SectionHeader(title:, action:)`；设置页 `SettingsSection` 内部已复用它 |
| 圆角/间距 | 写死 `circular(8/12)`、`20`、`6` | `AppRadius` / `AppSpacing` |

还有两处是「知道但本轮没动」的，改到相关代码时再处理：

| 位置 | 情况 | 建议 |
| --- | --- | --- |
| `lib/widgets/webview.dart` 的 `progressNotifier` | 有值没人读，博客页加载时没有进度条 | 需要时在 `SliverWebview` 上方加一条 `LinearProgressIndicator`，或删掉这个 notifier |
| `lib/blog/view/home_page.dart` 的返回键 | webview 退到底时直接 `SystemNavigator.pop()` 退出应用 | 与存储首页「先回上一级」的行为对齐前，先确认产品上想要哪种 |

---

## 12. 逐页对照表

| 页面 | 入口文件 | 骨架 | 用到的组件 | 要点 |
| --- | --- | --- | --- | --- |
| 存储首页 | `lib/storage/view/home_page.dart` | `MyHomePage`（大标题 FAB） | `EntryRow`（「所有位置」，只在未筛选时显示）、`SectionHeader` + `IconButton`（吸顶分组）、`ContentRow`、`ContentDivider`、`ListBottomPadding`、`SliverInfiniteList` | 四个分组按顺序：过期物品 / 即将过期 / 最近修改 / 最近录入，各一个吸顶头，空的分组不渲染；分组头右侧是展开/收起；FAB 添加物品；返回键从筛选态回「全部」 |
| 位置详情 | `lib/storage/view/storage_detail_page.dart` | `MySliverScaffold` + 普通 AppBar | 顶部路径栏 `PathBarDelegate`（48 高）、`StorageItemList`（位置在前、物品在后）、`ContentRow`、`ContentDivider`、`ListBottomPadding`、`SliverCenterLoadingIndicator`、`SliverErrorState` | AppBar 右上角依次：添加位置、搜索、更多菜单（编辑 / 删除 / 二维码）；删除走 `showConfirmDialog(destructive: true)`；下拉刷新 |
| 搜索 | `lib/storage/view/search_page.dart` | `MySliverScaffold` + `AppBarSize.normal`，标题位放 `SearchBar` | `SearchBar`（高 48、无阴影）+ `MyChoiceChip`（已删除 / 无位置，`appbarBottom` 高 56）、`StorageItemList`（`isHighlight: true`）、`SliverEmptyState`、`SliverErrorState` | 三态都要有：刚进页面 / 搜不到 / 出错；输入防抖 300 毫秒；清除按钮 20 图标 + `tooltip: '清除'` |
| 回收站 | `lib/storage/view/recycle_bin_page.dart` | `MySliverScaffold` + 普通 AppBar | `ContentRow`（`trailing` 一个恢复按钮）、`ContentDivider`、`SliverInfiniteList`、`SliverErrorState`、`SliverCenterLoadingIndicator` | 副标题「3 天前删除 · 备注」；恢复前先确认（非危险，`destructive: false`），恢复中给 1 秒提示 |
| 耗材管理 | `lib/storage/view/consumables_page.dart` | `MySliverScaffold` + 普通 AppBar | `SectionHeader`（右侧 `TextButton('查看')`）、`ContentRow`（`trailing` 显示 `× N`）、`ContentDivider`、`SliverInfiniteList` | 每个物品一个小节；没有耗材时该节显示一行 `bodyMedium` + `onSurfaceVariant` 的「没有耗材」 |
| 物品详情 | `lib/storage/view/item_detail_page.dart` | `MySliverScaffold` + 普通 AppBar | `SectionHeader`（基本信息 / 耗材 / 记录 / 图片）、`InfoRow`（标签-值）、`ContentRow`（耗材、图片）、`ContentDivider`、`ListBottomPadding`、`SliverCenterLoadingIndicator`、`SliverErrorState` | 三态由 `state.when` 分（data / loading / error）；AppBar 右上角搜索 + 更多菜单（编辑 / 添加图片 / 耗材编辑 / 删除）；正文包 `SelectionArea` 方便复制 |
| 留言板列表 | `lib/board/view/home_page.dart` | `MyHomePage`（FAB 添加话题） | `TopicItem`（内部 `ListTile` + `MyCircleAvatar`）、`ContentDivider`、`SliverInfiniteList`、`ListBottomPadding`、`SliverErrorState`、`SliverCenterLoadingIndicator` | 标题占两行（`maxLines: 2`）；副标题「作者 · 最近回复 3 小时前」单行（相对时间，不占两行）；置顶 / 关闭用小图标 16 放在标题前 |
| 话题详情 | `lib/board/view/topic_detail_page.dart` | `MySliverScaffold` + 普通 AppBar | `ItemTitle`（头像 + 作者 + 时间 + 菜单）、`MyMarkdownBody`、`CommentItem`、`SliverInfiniteList`、`SliverCenterLoadingIndicator`、`SliverErrorState` | 标题在 AppBar；正文标题用 `headlineSmall`；「全部评论」用 `SectionHeader` + 带 tooltip 的排序菜单；评论之间 `ContentDivider`，底部 `ListBottomPadding`；话题关闭后不显示评论 FAB；删除 / 置顶 / 关闭都要先确认 |
| 设置 | `lib/core/view/settings/settings_page.dart` | `MySliverScaffold` + 普通 AppBar | `SettingsList` + `SettingsSection` + `SettingsTile` | 分组：通用 / 博客 / 留言板；有下级的行 `subtitle` 显示当前值（主题、网址、排序）；二级页（主题、网址、推送）沿用同一套 `SettingsSection` |
| 表单页（物品 / 位置） | `lib/storage/view/item_edit_page.dart`、`storage_edit_page.dart` | `MySliverScaffold` + `AppBarSize.normal` + `SliverFillRemaining(hasScrollBody: false)` | `Form` + `TextFormField`（主题样式）、`StorageFormField`、`DateTimePickerFormField`、`RoundedRaisedButton`（整宽） | 字段间距 12、左右 16；提交中禁用按钮；成功后 `pop(true)` 让上一页刷新；失败 `showErrorSnackBar` |
| 表单页（话题 / 评论） | `lib/board/view/topic_edit_page.dart`、`comment_edit_page.dart` | `MySliverScaffold` + `TabBar` 作为 `appbarBottom`（自动普通 AppBar） | `TabBarView`（编辑 / 预览两页）、`TextFormField`、`MyMarkdownBody`（预览） | 预览页复用 `TopicItem(showBody: true)`；编辑区左右内边距待从 8 收到 16 |
| 表单页（图片 / 耗材） | `lib/storage/view/picture_add_page.dart`、`consumable_edit_page.dart` | `MySliverScaffold`（仍是大标题，待收口） | `RoundedRaisedButton`、`EmptyState`（没有图片时）、`ListTile` + `IconButton`（耗材行） | 图片页上传按钮整宽并留 `SafeArea`；耗材页的空态待换成 `EmptyState` |
| 单字段设置 | `lib/core/view/settings/api_url_page.dart` 等 | `MySliverScaffold` + 普通 AppBar | `TextEditPage`（一个输入框 + AppBar 勾号保存） | 例外用法，条件见 7.5 |
| 博客（补充） | `lib/blog/view/home_page.dart` | `MyHomePage` | `SliverWebview`、`SliverCenterRoundedRaisedButton`、`FloatingActionButton`（用浏览器打开） | WebView 为主；`canPop` 拦截返回，能回退就回退 WebView，否则退出应用 |

---

## 13. 改界面的流程

1. **先改常量，再改页面**。要新间距 / 圆角，先加进 `dimens.dart`；要新按钮样式，先加进 `theme.dart`。反过来（先在页面里写数字）评审必打回。
2. **优先复用，其次新建组件**。同一段界面在第二个页面出现了，就抽到 `lib/widgets/`，并在本文第 0 节登记。
3. **状态三件套别漏**：新页面必须先想清楚空、错、加载各自长什么样。
4. **自查清单**：
   - 页面里还有 `Color(`、`fontSize`、`EdgeInsets.` 直接写数字吗？
   - 列表行有传空字符串副标题吗？
   - 每个 `IconButton` 都有 `tooltip` 吗？
   - 列表底部有 `ListBottomPadding` 吗？
   - 危险操作有 `destructive: true` 吗？
   - 宽屏（≥ 720）下拉宽正常吗？
5. **跑检查**：`flutter analyze --no-pub`。界面改动涉及逻辑时再跑 `flutter test --no-pub`。
6. 提交信息用 conventional commit，中文描述，例如 `style(ui): 列表行副标题为空时不再撑高`。

---

本文件由 DSH 生成
