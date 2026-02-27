# Rose Weapon Pack Refactor Playbook

## 1. 文档定位
- 本文是 `rose_equip_pack` 的长期重构、扩展架构设计与配置执行综合手册。
- 目标读者：后续持续接入、维护玫瑰系武器的开发者。
- 当前基线：采用 `Resolver + Builder + Factory + Runtime` 的运行时动态装配架构。

## 2. 核心架构设计

### 2.1 分层职责与设计模式
系统基于 `Runtime + Strategy + Resolver + Factory` 模式设计：

- **入口层**（`modmain.lua` / `modinfo.lua`）
  - 注册 `PrefabFiles`。
  - 读取 mod 配置，写入 `TUNING.ROSE_EQUIP_PACK_CONFIG`、`TUNING.ROSE_EQUIP_PACK_DIFFICULTY_MODE`、`TUNING.ROSE_EQUIP_PACK_REPAIRABLE_ENABLED`。
  - 负责按语言导入 `rose_equip_strings_cns.lua` / `rose_equip_strings_en.lua`。
  - 导入字符串与配方注册脚本。

- **基础数据层**（`scripts/util/rose_equip_data.lua`）
  - 存放武器静态参数与能力默认值（伤害、攻距、能力默认开关、可选组件数据等）。
  - 不承载难度档位差异逻辑。

- **难度策略层**（`scripts/rose_core/rose_difficulty_profiles.lua`）
  - 定义 `newbie` / `vanilla` 的 `defaults` 与 `weapon_overrides`。
  - 负责配方、基础伤害倍率、装备增益策略差异。
  - 负责修补策略差异（`repair.values`）与按档位覆写耐久上限（`max_uses`）。

- **解析层**（`scripts/rose_core/rose_weapon_data_resolver.lua`）
  - 合并 `rose_equip_data` 与 `rose_difficulty_profiles`。
  - 输出统一的 `equip/combat/recipe_data/repair/max_uses`，并提供 `resolve_recipe_data` 给配方注册层。

- **定义构建层**（`scripts/rose_defs/weapon_def_builder.lua`）
  - 将解析结果转换为运行时武器定义（能力顺序、能力模块映射、成长曲线等）。

- **运行时配置层**（`scripts/rose_core/rose_config_runtime.lua`）
  - 按优先级读取配置：`ROSE_EQUIP_PACK_CONFIG` -> 兼容旧表 `*_CONFIG` -> `GetModConfigData`。
  - 生成 `runtime_config`（武器开关 + 能力开关/参数）。

- **运行时工厂层**（`scripts/rose_core/rose_weapon_factory.lua`）
  - 统一挂载 `rose_weapon_runtime` 组件并执行 `Setup(weapon_def, runtime_config)`。

- **Prefab 组装层**（`scripts/prefabs/prefab_<weapon>.lua` + `scripts/rose_prefab/*`）
  - `prefab_component_installers.lua` 负责通用/战斗/可选组件安装。
  - 统一安装 `trader` 入口，走 `can_accept_item/on_accept_item/on_refuse_item` 链路。
  - 统一处理耐久归零行为：开修补模式进入损坏态；关修补模式走原版移除。
  - `prefab_inventory_image_anim.lua` 负责背包动图。
  - `rose_prefab_tuning.lua` 负责灯光与 prefab 参数归一化。
  - `prefab_sakura_fx.lua` 负责统一樱花特效控制。

- **运行时组件层**（`scripts/components/rose_weapon_runtime.lua`）
  - 统一管理动态状态、事件分发、能力调用、伤害计算入口、存档读写。
  - 承担修补判定与执行：`CanAcceptRepairItem`、`TryRepairByItem`、`CanAcceptTradeItem`、`OnRefuseItem`。
  - 通过 `REPAIR_BROKEN_TAG` 控制 0 耐久时能力失效。

- **文本层**（`scripts/util/rose_equip_strings_cns.lua` / `scripts/util/rose_equip_strings_en.lua`）
  - 统一维护武器名/描述/配方文本。
  - 统一维护修补提示台词命名空间：`STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES`。
  - 统一维护 `ACTIONS.USEITEM` 的文案与 `strfn` 包装逻辑（阳伞/乌鸦镰刀开关文本）。

- **内核服务层**（`scripts/rose_core/damage_pipeline.lua` / `scripts/rose_core/progression_service.lua`）
  - 处理伤害管线与成长曲线结算。

- **能力插件层**（`scripts/rose_abilities/ability_<id>.lua`）
  - 通过 `OnAttackPre/OnAttackPost/OnEquip/OnCastSpell` 等钩子参与运行时。

### 2.2 关键行为链路
- **配置加载链路**：`modinfo.lua` 定义配置项 -> `modmain.lua` 读取并写入 `TUNING`。
- **配方注册链路**：`util/rose_equip_recipes.lua` 调用 `resolve_recipe_data` -> `AddRecipe2`。
- **武器实例化链路**：Prefab 读取 `resolve_weapon_data` -> 安装组件 -> `weapon_factory.attach_runtime` -> `runtime:Setup`。
- **战斗链路**：`OnAttackPre` -> `ApplyAttackDamage` -> `OnAttackPost`。
- **状态持久化链路**：统一由 `rose_weapon_runtime:OnSave/OnLoad` 托管。
- **修补链路**：`trader:SetAcceptTest` -> `runtime:CanAcceptTradeItem` -> `runtime:OnAcceptItem`（优先 `TryRepairByItem`）-> `inst._rose_on_repaired` -> 清理损坏态并恢复能力。
- **拒绝提示链路**：`trader:SetOnRefuse` -> `runtime:OnRefuseItem` -> `STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES` 对应文案。
- **损坏态链路**：耐久归零触发 `set_broken_state`，打上 `rose_repair_broken`，武器伤害/平面伤害/工具行为归零，修复后由 `clear_broken_state` 统一恢复。

### 2.3 Prefab 二阶段抽象（已落地）
- 目标：降低武器 prefab 样板代码，统一组件安装与动图/灯光行为。
- 动图控制器：`scripts/rose_prefab/prefab_inventory_image_anim.lua`
- 组件安装器：`scripts/rose_prefab/prefab_component_installers.lua`
- 参数调优：`scripts/rose_prefab/rose_prefab_tuning.lua`
- 方案文档：`docs_dev/other/rose_equip_pack/prefab_stage2_abstraction_plan.md`

## 3. 配置读取与解析链路

### 3.1 链路流程
1. `modmain.lua` 读取 `rose_equip_pack_difficulty_mode`、`rose_equip_pack_repairable_enabled` 与武器总开关，写入 `TUNING`。
2. `rose_weapon_data_resolver.resolve_weapon_data(id)` 合并基础数据与难度覆写（含 `repair/max_uses`）。
3. `weapon_def_builder.build(id)` 生成运行时武器定义（能力顺序/模块/成长曲线）。
4. `rose_config_runtime.build_weapon_config(weapon_def)` 合成运行时开关配置。
5. `rose_weapon_factory.attach_runtime(inst, weapon_def)` 挂载并初始化 `rose_weapon_runtime`。
6. `rose_weapon_runtime` 在 `Setup` 中按顺序加载并初始化能力模块。
7. `rose_equip_recipes.lua` 通过 `resolve_recipe_data` 注册当前难度配方。

### 3.2 字段维护与演进建议（Schema）
- 平衡性调整（配方、倍率、装备增益、修补材料/数值）优先修改 `rose_difficulty_profiles.lua`。
- 武器共性结构调整优先收敛到 `rose_config_runtime.lua` 与 `rose_prefab/*`，避免 prefab 分叉。
- `modinfo.lua` 当前仅开放武器级总开关；能力级开关默认由数据层与运行时配置统一控制。
- 修补台词统一使用 `STRINGS.ROSE_EQUIP_PACK_REPAIR_LINES`，避免在运行时代码硬编码文本。

### 3.3 修补系统字段约定
- `rose_difficulty_profiles.lua`：
  - `weapon_overrides.<weapon_id>.repair.values.<item_prefab> = uses`
  - `weapon_overrides.<weapon_id>.max_uses = number`（用于档位覆盖耐久上限）
- `rose_weapon_data_resolver.lua`：
  - 输出 `resolved.repair = { enabled, values }`
  - 输出 `resolved.repair_values`（兼容字段）
  - 输出 `resolved.max_uses`
- `weapon_def_builder.lua`：
  - 透传 `repair.enabled` 与 `repair.values` 到 `weapon_def`
- `prefab_component_installers.lua`：
  - `is_repairable_mode_enabled == true`：`finiteuses:SetOnFinished(set_broken_state)`，不移除实体
  - `is_repairable_mode_enabled == false`：`finiteuses:SetOnFinished(inst.Remove)`，保持旧行为

## 4. 新武器接入 SOP（严格按顺序）
1. 在 `scripts/util/rose_equip_data.lua` 新增武器静态数据（含 abilities/tool_actions/spell 等可选字段）。
2. 在 `scripts/rose_core/rose_difficulty_profiles.lua` 的 `newbie/vanilla` 中补齐配方、修补材料/修补量与必要的耐久覆写。
3. 创建 `scripts/prefabs/prefab_<weapon>.lua`，按现有 prefab 模板接入：
   - `resolve_weapon_data("<id>")`
   - `weapon_def_builder.build("<id>")`
   - `component_installers.install_*`
   - `weapon_factory.attach_runtime(...)`
4. 在 `scripts/util/rose_equip_recipes.lua` 的 `weapon_ids` 中注册新武器配方 ID。
5. 如需要樱花雨，在 `scripts/prefabs/particle_sakura_rain_all.lua` 增加对应 prefab 绑定。
6. 更新 `rose_equip_strings_*.lua`（含修补台词命名空间），并同步 `modmain.lua` 的 `PrefabFiles` 与 `modinfo.lua` 展示信息。

## 5. 开发红线与能力准则（强制）
- **基准分离**：`rose_equip_data.lua` 放基准参数，难度差异必须进 `rose_difficulty_profiles.lua`。
- **禁止 prefab 私有平衡分支**：不允许在 `scripts/prefabs` 内手写平衡数据副本。
- **配置入口统一**：运行时配置统一经 `rose_config_runtime.lua` 读取，避免各能力直接散读 `GetModConfigData`。
- **服务边界清晰**：伤害与成长计算统一走 `damage_pipeline.lua` / `progression_service.lua`。
- **修补行为统一**：所有修补判定/提示必须走 `rose_weapon_runtime` 与 `prefab_component_installers` 统一入口，禁止在单个 prefab 分叉实现。

## 6. 文档索引
1. 总手册（本文）：`docs/rose_weapon_pack_refactor_playbook.md`
2. 创意工坊介绍页文稿：`docs/release/rose_equip_pack_workshop_intro.md`
3. 双难度实现方案：`docs/difficulty_mode_dual_profile_plan.md`
