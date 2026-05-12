import { CalendarClock, Mail, Phone, UserRound } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody } from '../components/ui/Card'
import { Badge, statusTone } from '../components/ui/Badge'
import { ErrorState, LoadingState } from '../components/ui/States'
import { getApresentadoras } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asString } from '../utils/format'

export function ApresentadorasPage() {
  const query = useQuery({ queryKey: ['apresentadoras'], queryFn: getApresentadoras })

  if (query.isLoading) return <LoadingState />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  return (
    <div className="space-y-6">
      <PageHeader eyebrow="Operação" accent="Equipe" title="de apresentadoras" subtitle="Cadastro e disponibilidade para lives." />
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {(query.data ?? []).map((item, index) => (
          <Card key={asString(item.id, String(index))}>
            <CardBody>
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-3">
                  <span className="rounded-lg bg-brand-soft p-3 text-brand">
                    <UserRound className="h-5 w-5" />
                  </span>
                  <div>
                    <p className="text-base font-bold text-ink">{asString(item.nome ?? item.name, 'Apresentadora')}</p>
                    <p className="mt-1 text-xs text-ink-muted">{asString(item.especialidade ?? item.bio, 'perfil operacional')}</p>
                  </div>
                </div>
                <Badge tone={statusTone(asString(item.status ?? item.ativo, ''))}>{asString(item.status ?? (item.ativo ? 'ativo' : 'inativo'))}</Badge>
              </div>
              <div className="mt-5 space-y-2 text-sm text-ink-muted">
                <p className="flex items-center gap-2"><Mail className="h-4 w-4" /> {asString(item.email)}</p>
                <p className="flex items-center gap-2"><Phone className="h-4 w-4" /> {asString(item.telefone)}</p>
                <p className="flex items-center gap-2"><CalendarClock className="h-4 w-4" /> {asString(item.disponibilidade, 'disponibilidade via agenda')}</p>
              </div>
            </CardBody>
          </Card>
        ))}
      </section>
    </div>
  )
}
