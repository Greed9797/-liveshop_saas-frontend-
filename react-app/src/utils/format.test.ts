import { describe, expect, it } from 'vitest'
import { asNumber, periodToParam, shiftPeriod, unwrapList } from './format'

describe('format utilities', () => {
  it('normalizes numeric strings from API payloads', () => {
    expect(asNumber('1.234,50')).toBe(1234.5)
    expect(asNumber(42)).toBe(42)
    expect(asNumber(null, 7)).toBe(7)
  })

  it('serializes month and year filters for backend period params', () => {
    expect(periodToParam({ mes: 5, ano: 2026 })).toBe('2026-05')
    expect(shiftPeriod({ mes: 1, ano: 2026 }, -1)).toEqual({ mes: 12, ano: 2025 })
  })

  it('unwraps common backend list envelopes', () => {
    expect(unwrapList({ items: [{ id: 1 }] })).toEqual([{ id: 1 }])
    expect(unwrapList([{ id: 2 }])).toEqual([{ id: 2 }])
  })
})
