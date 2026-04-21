# Spec Revision

## Prior rejected spec
- `.omx/plans/autopilot-spec.md`（上一版已被标记 INVALIDATED）
- `.omx/plans/autopilot-impl.md`（上一版已被标记 INVALIDATED）

## User correction
用户纠正点不是措辞问题，而是逻辑层级问题：旧 spec 最多只是承认 edges 仍有缺口，绝不是已经承诺或完成 native channel / relation contract。当前实现继续使用 capture / snapshot / observation 的混合链路，因此不能被包装成“更原生的 channel contract”。本轮必须从 spec 重新开始，并且不要在旧代码上修补。

## What was wrong before
- 把“已识别缺口”误读成“已完成 native contract”。
- 把 descriptive edges / flow rows 误包装成 first-class relation truth。
- 默认沿旧 `scripts/cdda_web_server.py` 继续增量修改，违背了用户要求的 clean rebuild path。

## Revised intent
以 greenfield 方式定义 relation-first contract：relations 拥有独立 schema、独立 store、独立 UI section、独立 lifecycle，不再从旧 topology rows 倒推出 edge truth。

## Revised mock requirement
先提交一个明确区分 raw / captured / derived / native-relation 的 mock；mock 必须展示“relation 缺失时如何诚实显示缺口”，而不是用旧 edge rows 冒充完成态。

## Implementation status
Not started.
