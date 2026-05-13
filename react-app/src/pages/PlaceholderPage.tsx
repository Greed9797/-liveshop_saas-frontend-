import { useQuery } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { DataTable } from '../components/ui/DataTable'
import { ErrorState, LoadingState } from '../components/ui/States'
import { apiGet, extractErrorMessage } from '../services/api'
import { asString, unwrapList } from '../utils/format'
import type { JsonRecord } from '../types/models'

export function PlaceholderPage({ title, endpoint }: { title: string; endpoint: string }) {
  const path = endpoint.replace('/v1', '')
  const query = useQuery({ queryKey: ['generic-page', endpoint], queryFn: () => apiGet<JsonRecord[] | JsonRecord>(path) })

  if (query.isLoading) return <LoadingState />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  const data = unwrapList<JsonRecord>(query.data)
  const columns = Object.keys(data[0] ?? {}).slice(0, 5)

  return (
    <div className="space-y-6">
      <PageHeader accent={title} title="" subtitle={`Dados conectados em ${endpoint}.`} />
      <Card>
        <CardHeader>
          <p className="text-sm font-bold text-ink">{title}</p>
        </CardHeader>
        <CardBody>
          {columns.length ? (
            <DataTable<JsonRecord>
              data={data}
              columns={columns.map((column) => ({
                key: column,
                header: column.replace(/_/g, ' '),
                render: (item) => asString(item[column]),
              }))}
            />
          ) : (
            <pre className="overflow-auto rounded-2xl bg-surface-muted p-4 text-xs text-ink-muted">{JSON.stringify(query.data ?? {}, null, 2)}</pre>
          )}
        </CardBody>
      </Card>
    </div>
  )
}
