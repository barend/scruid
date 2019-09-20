package ing.wbaa.druid.auth.krb5

import akka.http.scaladsl.model.headers.{ Authorization, OAuth2BearerToken }
import akka.http.scaladsl.model.{ HttpRequest, HttpResponse, StatusCodes }
import com.typesafe.config.{ Config, ConfigFactory }
import ing.wbaa.druid.client.{ RequestInterceptor, RequestInterceptorBuilder }
import org.slf4j.LoggerFactory

import scala.concurrent.{ ExecutionContext, Future }

/** Experimental code, do not use. */
class KerberosAuthenticationExtension extends RequestInterceptor {
  private var cachedTicket: Option[String] = None

  def interceptRequest(request: HttpRequest): HttpRequest =
    cachedTicket
      .map { ticket =>
        request.withHeaders(Authorization(OAuth2BearerToken(ticket)))
      }
      .getOrElse(request)

  def interceptResponse(
      request: HttpRequest,
      response: Future[HttpResponse],
      sendToDruid: HttpRequest => Future[HttpResponse]
  )(implicit ec: ExecutionContext): Future[HttpResponse] =
    response.map(_.status).flatMap {
      case StatusCodes.Unauthorized =>
        KDC.getTicket().flatMap { ticket =>
          cachedTicket = Some(ticket)
          sendToDruid(request)
        }
      case _ => response

    }

  override def exportConfig: Config = ConfigFactory.empty()
}

object KerberosAuthenticationExtension extends RequestInterceptorBuilder {
  val logger = LoggerFactory.getLogger(classOf[KerberosAuthenticationExtension])

  override def apply(config: Config): RequestInterceptor = {
    logger.warn("Using non-working prototype Kerberos extension")
    new KerberosAuthenticationExtension
  }

}
