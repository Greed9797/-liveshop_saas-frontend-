import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { Shell } from '../components/layout/Shell'
import { cabineRoles, clienteRoles, commercialRoles, financeRoles, internalRoles, masterRoles, opsRoles } from '../utils/access'
import { ProtectedRoute } from './ProtectedRoute'
import { LoginPage } from '../pages/LoginPage'
import { ForgotPasswordPage } from '../pages/ForgotPasswordPage'
import { DashboardPage } from '../pages/DashboardPage'
import { MasterDashboardPage } from '../pages/MasterDashboardPage'
import { MasterUnitsPage } from '../pages/MasterUnitsPage'
import { MasterConsolidatedPage } from '../pages/MasterConsolidatedPage'
import { CrmPage } from '../pages/CrmPage'
import { ClienteDashboardPage } from '../pages/ClienteDashboardPage'
import { ClienteLivesPage } from '../pages/ClienteLivesPage'
import { ClienteAgendaPage } from '../pages/ClienteAgendaPage'
import { CabinesPage } from '../pages/CabinesPage'
import { SolicitacoesPage } from '../pages/SolicitacoesPage'
import { AnalyticsPage } from '../pages/AnalyticsPage'
import { ApresentadorasPage } from '../pages/ApresentadorasPage'
import { FinanceiroPage } from '../pages/FinanceiroPage'
import { ConfiguracoesPage } from '../pages/ConfiguracoesPage'
import { KnowledgePage } from '../pages/KnowledgePage'
import { BoletosPage } from '../pages/BoletosPage'
import { OnboardingPage } from '../pages/OnboardingPage'
import { NotFoundPage } from '../pages/NotFoundPage'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/esqueci-senha" element={<ForgotPasswordPage />} />

        <Route element={<ProtectedRoute allowedRoles={clienteRoles} />}>
          <Route path="/onboarding" element={<OnboardingPage />} />
        </Route>

        <Route element={<ProtectedRoute />}>
          <Route element={<Shell />}>
            <Route element={<ProtectedRoute allowedRoles={internalRoles} fallback="/master" />}>
              <Route index element={<DashboardPage />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={masterRoles} />}>
              <Route path="/master" element={<MasterDashboardPage />} />
              <Route path="/master/unidades" element={<MasterUnitsPage />} />
              <Route path="/master/consolidado" element={<MasterConsolidatedPage />} />
              <Route path="/master/franqueados" element={<MasterUnitsPage title="Franqueados" mode="franqueados" />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={[...masterRoles, ...commercialRoles]} />}>
              <Route path="/master/crm" element={<CrmPage />} />
              <Route path="/leads" element={<Navigate to="/master/crm" replace />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={['cliente_parceiro']} />}>
              <Route path="/cliente" element={<ClienteDashboardPage />} />
              <Route path="/cliente/dashboard" element={<Navigate to="/cliente" replace />} />
              <Route path="/cliente/lives" element={<ClienteLivesPage />} />
              <Route path="/cliente/agenda" element={<ClienteAgendaPage />} />
              <Route path="/cliente/configuracoes" element={<ConfiguracoesPage clienteMode />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={cabineRoles} />}>
              <Route path="/cabines" element={<CabinesPage />} />
              <Route path="/agendamentos" element={<Navigate to="/solicitacoes" replace />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={opsRoles} />}>
              <Route path="/solicitacoes" element={<SolicitacoesPage />} />
              <Route path="/apresentadoras" element={<ApresentadorasPage />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={[...financeRoles, ...commercialRoles]} />}>
              <Route path="/analytics-dashboard" element={<AnalyticsPage />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={financeRoles} />}>
              <Route path="/financeiro" element={<FinanceiroPage />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={[...financeRoles, 'cliente_parceiro']} />}>
              <Route path="/boletos" element={<BoletosPage />} />
            </Route>

            <Route element={<ProtectedRoute allowedRoles={['franqueador_master', 'franqueado']} />}>
              <Route path="/configuracoes" element={<ConfiguracoesPage />} />
            </Route>

            <Route path="/conhecimento" element={<KnowledgePage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Route>
        </Route>
      </Routes>
    </BrowserRouter>
  )
}
